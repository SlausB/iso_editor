///@cond
package blisc.utils
{
	import blisc.core.Blisc;
	import blisc.instances.BliscCompound;
	import blisc.pathfinding.AStarNode;
	import blisc.templates.BliscComplexTemplate;
	import blisc.templates.BliscComplexWithinCompoundTemplate;
	import blisc.templates.BliscCompoundTemplate;
	import blisc.templates.BliscObjectTemplate;
	import blisc.templates.BliscRegion;
	import blisc.templates.BliscRegionWithinComplex;
	import com.junkbyte.console.Cc;
	import flash.display.Sprite;
	import flash.geom.Point;
	import utils.Utils;
	
	///@endcond
	
	
	/** Checks if specified object can be put on specified position and draws overlapping tiles if not.*/
	public class Fitting extends Sprite
	{
		public var _object : BliscObjectTemplate;
		public var _tryingTileX : Number = 0;
		public var _tryingTileY : Number = 0;
		
		private var _canPut : Boolean = false;
		
		private var _overlappings : Vector.< Overlapping > = new Vector.< Overlapping >;
		
		/** Object can be put regardless default check.*/
		public static const OVERCHECK_ALLOW : int = 1;
		/** Object CANNOT be put regardless default check.*/
		public static const OVERCHECK_REFUSE : int = 2;
		/** Default check must be used.*/
		public static const OVERCHECK_DEFAULT : int = 3;
		
		
		public function Fitting( object : BliscObjectTemplate )
		{
			mouseChildren = false;
			mouseEnabled = false;
			
			_object = object;
		}
		
		/**
		\param overcheck function( node : AStarNode, region : BliscRegion ) : int Specify if this function must be used to check if object's <b>region</b> can be put on <b>node</b>. Must return one of OVERCHECK_... constants.
		*/
		public function TryOn( pBlisc : Blisc, tileX : Number, tileY : Number, overcheck : Function = null ) : void
		{
			_tryingTileX = tileX;
			_tryingTileY = tileY;
			
			CleanUp();
			
			_canPut = true;
			
			if ( _object is BliscComplexTemplate )
			{
				TryComplex( pBlisc, _object as BliscComplexTemplate, tileX, tileY, 0, 0, overcheck );
			}
			else if ( _object is BliscCompoundTemplate )
			{
				var compound : BliscCompoundTemplate = _object as BliscCompoundTemplate;
				for each ( var bcwct : BliscComplexWithinCompoundTemplate in compound._complexes )
				{
					TryComplex( pBlisc, bcwct._complex, tileX, tileY, bcwct._tileDisp.x, bcwct._tileDisp.y, overcheck );
				}
			}
			else
			{
				Cc.error( "E: Fitting.TryOn(): wrong object type." );
				_canPut = false;
			}
			
			for each ( var overlapping : Overlapping in _overlappings )
			{
				overlapping.Render();
			}
		}
		
		private function TryComplex( pBlisc : Blisc, complex : BliscComplexTemplate, globalTileX : Number, globalTileY : Number, relativeTileX : Number, relativeTileY : Number, overcheck : Function ) : void
		{
			const resultRoundX : int = Math.round( globalTileX + relativeTileX );
			const resultRoundY : int = Math.round( globalTileY + relativeTileY );
			
			for each ( var region : BliscRegionWithinComplex in complex._regions )
			{
				if ( region._region._type != BliscRegion.TYPE_SPACE )
				{
					continue;
				}
				
				for each ( var tile : Point in region._tiles )
				{
					const resultGlobalX : int = resultRoundX + tile.x;
					const resultGlobalY : int = resultRoundY + tile.y;
					
					var node : AStarNode = pBlisc._aStar.grid.GetTile( resultGlobalX, resultGlobalY, false );
					
					const resultRelativeX : int = Math.round( relativeTileX ) + tile.x;
					const resultRelativeY : int = Math.round( relativeTileY ) + tile.y;
					
					var permitting : Boolean = true;
					
					var tempCanPut : Boolean = true;
					
					//you cannot put objects outside of playing area:
					if ( node == null )
					{
						tempCanPut = false;
					}
					else if ( overcheck != null )
					{
						var overcheckResult : int = OVERCHECK_DEFAULT;
						try
						{
							overcheckResult = overcheck( node, region._region );
						}
						catch ( e : Error )
						{
							Cc.error( "E: Fitting.TryComplex(): call to overchecking function failed with \"" + e.message + "\"." );
						}
						
						switch ( overcheckResult )
						{
							case OVERCHECK_ALLOW:
								tempCanPut = true;
								break;
							
							case OVERCHECK_REFUSE:
								tempCanPut = false;
								break;
							
							case OVERCHECK_DEFAULT:
								tempCanPut = node.CanPutOn( region._region );
								break;
						}
					}
					else
					{
						tempCanPut = node.CanPutOn( region._region );
					}
					
					if ( tempCanPut == false )
					{
						_canPut = false;
						
						permitting = false;
					}
					
					var already : Boolean = false;
					for each ( var overlapping : Overlapping in _overlappings )
					{
						if ( overlapping._relativeTileX == resultRelativeX && overlapping._relativeTileY == resultRelativeY )
						{
							if ( permitting == false )
							{
								overlapping._permitting = permitting;
							}
							already = true;
							break;
						}
					}
					
					if ( already == false )
					{
						var newOverlapping : Overlapping = new Overlapping( pBlisc.tileSide, resultRelativeX, resultRelativeY, permitting );
						_overlappings.push( newOverlapping );
						addChild( newOverlapping );
					}
				}
			}
		}
		
		public function get canPut() : Boolean
		{
			return _canPut;
		}
		
		public function Destroy() : void
		{
			CleanUp();
			
			_object = null;
		}
		
		private function CleanUp() : void
		{
			for each ( var overlapping : Overlapping in _overlappings )
			{
				overlapping.Destroy();
			}
			_overlappings.length = 0;
		}
		
	}

}
import blisc.core.Blisc;
import flash.display.Sprite;
import flash.geom.Point;
import utils.Utils;

class Overlapping extends Sprite
{
	public var _tileSide : Number;
	
	public var _relativeTileX : int;
	public var _relativeTileY : int;
	
	public var _permitting : Boolean;
	
	
	public function Overlapping( tileSide : Number, relativeTileX : int, relativeTileY : int, permitting : Boolean )
	{
		_tileSide = tileSide;
		
		_relativeTileX = relativeTileX;
		_relativeTileY = relativeTileY;
		
		_permitting = permitting;
		
		
		Render();
	}
	
	public function Render() : void
	{
		graphics.beginFill( _permitting ? 0x00FF00 : 0xFF0000 );
		var pos : Point = new Point;
		//north:
		graphics.moveTo( 0, 0 );
		//east:
		Utils.FromIso( _tileSide, 0, pos );
		graphics.lineTo( pos.x, pos.y );
		//south:
		Utils.FromIso( _tileSide, _tileSide, pos );
		graphics.lineTo( pos.x, pos.y );
		//west:
		Utils.FromIso( 0, _tileSide, pos );
		graphics.lineTo( pos.x, pos.y );
		//back to north:
		graphics.lineTo( 0, 0 );
		graphics.endFill();
		
		Utils.FromIso( _relativeTileX * _tileSide, _relativeTileY * _tileSide, pos );
		x = pos.x;
		y = pos.y;
	}
	
	public function Destroy() : void
	{
		Utils.Hide( this );
		
		graphics.clear();
	}
}



