/// @cond
package iso
{
	import com.adobe.serialization.json.JSON;
	import com.junkbyte.console.Cc;
	import iso.orient.Combination;
	import iso.orient.Orientation;
	import utils.Utils;
	
	/// @endcond
	
	/** Каждый тайл - это лишь сумма направлений к соседним тайлам. Эквивалент дороги.
	*/
	public class MorphDirs extends AbstractMorph
	{
		/** В этом варианте терраморфинга несуществующие комбинации не описаны должны восприниматься как тайлы этой же поверхности не примыкающие к соседям.*/
		private static const _emptyDirections : Vector.< int > = new Vector.< int >;
		
		
		public function MorphDirs( combination : Combination, opaqueData : *, getNeighbour : Function, onChange : Function, resolver : Function, type : int )
		{
			super( combination, opaqueData, getNeighbour, onChange, resolver, type );
		}
		
		private function MorphItself( toWhat : int ) : void
		{
			var thisDirections : Vector.< int > = new Vector.< int >;
			for ( var collectingIndex : int = 0; collectingIndex < Orientation.NEIGHBOURS; ++collectingIndex )
			{
				var collectingNeighbour : AbstractMorph = _getNeighbour( collectingIndex, _opaqueData );
				if ( collectingNeighbour != null && collectingNeighbour._type == toWhat )
				{
					thisDirections.push( collectingIndex );
				}
			}
			SmartApplyDirections( thisDirections, toWhat );
		}
		
		/** The same as DoMorph_Chain() but faster if _getNeighbour() isn't as slow as other part of that function.
		\sa DoMorph_Chain()\
		\param last True if tile only have to update itself without neighbours disturbing.
		*/
		public function DoMorph_Recursive( toWhat : int, itself : Boolean = true, last : Boolean = false ) : void
		{
			if ( itself )
			{
				MorphItself( toWhat );
			}
			
			if ( last )
			{
				return;
			}
			
			_type = toWhat;
			
			for ( var reevaluatingNeighbourIndex : int = 0; reevaluatingNeighbourIndex < Orientation.NEIGHBOURS; ++reevaluatingNeighbourIndex )
			{
				var reevaluatingNeighbour : MorphDirs = _getNeighbour( reevaluatingNeighbourIndex, _opaqueData );
				if ( reevaluatingNeighbour == null )
				{
					continue;
				}
				reevaluatingNeighbour.DoMorph_Recursive( reevaluatingNeighbour._type, true, true );
			}
		}
		
		/** Do the actual morphing into specified surface. Neighbour tiles will be correctely processed. Uses neighbours CHANGING aproach which reduces amount of _getNeighbour() calls comparing to DoMorph_Recursive() but more fat in other aspects.
		\param toWhat To which surface do the morphing.
		\param itself True if need to update this tile as well.
		*/
		public function DoMorph_Chain( toWhat : int, itself : Boolean = true ) : void
		{
			if ( itself )
			{
				MorphItself( toWhat );
			}
			
			//updating neighours:
			for ( var neighbourIndex : int = 0; neighbourIndex < Orientation.NEIGHBOURS; ++neighbourIndex )
			{
				const thisTile : int = Orientation.Mirror( neighbourIndex );
				
				var updatingNeighbour : MorphDirs = _getNeighbour( neighbourIndex, _opaqueData );
				if ( updatingNeighbour != null )
				{
					if ( updatingNeighbour._combination == null )
					{
						Cc.error( "E: MorphDirs.DoMorph(): neighbour has no combination." );
						continue;
					}
					var directions : Vector.< int > = updatingNeighbour._combination._directions.concat();
					
					if ( updatingNeighbour._type == toWhat )
					{
						directions.push( thisTile );
						
						//угловые (n, e, s, w) соседи всегда отсутствуют если нет хотя бы одного из прилегающих к этому углу соседей, поэтому восстанавливаем отсутствующие углы если появившиеся соседи позволяют это сделать:
						//если добавленный тайл является одним из возможных прилегающих к углу соседом:
						if ( ( neighbourIndex % 2 ) != 0 )
						{
							//уголок, раньше текущего прилегающего по часовой стрелке (берём все тайлы только относительно центрального, поэтому переводим уголок текущего соседа на индекс соседа центрального тайла):
							var previousFilling : MorphDirs = _getNeighbour( ( neighbourIndex + Orientation.NEIGHBOURS - 2 ) % Orientation.NEIGHBOURS, _opaqueData );
							if ( previousFilling != null && previousFilling._type == toWhat )
							{
								//наличие второго прилегающего тайла (позволяющий уголку существовать) можно не проверять - если его нет, то лишний уголок так-и-так будет удалён впоследствии:
								directions.push( ( thisTile + 1 ) % Orientation.NEIGHBOURS );
							}
							
							//тоже самое, только следующий угол по часовой стрелке:
							var nextFilling : MorphDirs = _getNeighbour( ( neighbourIndex + 2 ) % Orientation.NEIGHBOURS, _opaqueData );
							if ( nextFilling != null && nextFilling._type == toWhat )
							{
								directions.push( ( thisTile + Orientation.NEIGHBOURS - 1 ) % Orientation.NEIGHBOURS );
							}
						}
					}
					//между групп терраморфинга соседние тайлы однозначно должны отсоединяться:
					else
					{
						//удаляем направление к текущему тайлу:
						for ( var removingIndex : int = 0; removingIndex < directions.length; ++removingIndex )
						{
							if ( directions[ removingIndex ] == thisTile )
							{
								directions.splice( removingIndex, 1 );
								break;
							}
						}
					}
					
					Utils.Unify( directions );
					updatingNeighbour.SmartApplyDirections( directions, updatingNeighbour._type );
				}
			}
		}
		
		/** Соединение с угловым соседом имеется только если имеются оба прилегающих соседа.*/
		private function ProcessDirs( directions : Vector.< int > ) : void
		{
			function CheckAdjacent( index : int ) : Boolean
			{
				for each ( var direction : int in directions )
				{
					if ( direction == index )
					{
						return true;
					}
				}
				
				return false;
			}
			
			for ( var i : int = 0; i < Orientation.NEIGHBOURS; ++i )
			{
				//только углы:
				if ( ( i % 2 ) == 0 )
				{
					var dirIndex : int;
					for ( dirIndex = 0; dirIndex < directions.length; ++dirIndex )
					{
						if ( directions[ dirIndex ] == i )
						{
							break;
						}
					}
					
					//если обрабатываемый угол указан:
					if ( dirIndex < directions.length )
					{
						if ( CheckAdjacent( ( i + ( Orientation.NEIGHBOURS - 1 ) ) % Orientation.NEIGHBOURS ) == false || CheckAdjacent( i + 1 ) == false )
						{
							directions.splice( dirIndex, 1 );
						}
					}
				}
			}
		}
		
		/** \sa _emptyDirections */
		public function SmartApplyDirections( directions : Vector.< int >, toWhat : int ) : void
		{
			ProcessDirs( directions );
			
			ResolveCombination( directions, toWhat );
			if ( _combination == null )
			{
				ResolveCombination( _emptyDirections, toWhat );
				directions = _emptyDirections;
			}
			CallOnChange( directions );
		}
	}

}

