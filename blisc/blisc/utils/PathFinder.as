///@cond
package blisc.utils
{
	import blisc.core.Blisc;
	import blisc.instances.BliscComplex;
	import blisc.instances.BliscComplexWithinCompound;
	import blisc.instances.BliscCompound;
	import blisc.pathfinding.AStarNode;
	import blisc.pathfinding.Path;
	import blisc.templates.BliscRegion;
	import blisc.templates.BliscUnitTemplate;
	import com.junkbyte.console.Cc;
	
	///@endcond
	
	
	/** Find the path which ends next to specified isometric object.*/
	public class PathFinder
	{
		private var _path : Path = null;
		
		
		public function PathFinder( blisc : Blisc, movingTemplate : BliscUnitTemplate, from : AStarNode, to : BliscCompound )
		{
			var dimensions : Dimensions = new Dimensions( to );
			
			//could be treated as ordinary square but then there must be some exceptions:
			if ( dimensions._width == dimensions._height && dimensions._width == 1 )
			{
				var potentialPath : Path = blisc._aStar.search( movingTemplate, from, to.node, Resources.SLIPPING_VALUE, false, true );
				if ( potentialPath._complete )
				{
					_path = new Path( true, potentialPath._path.length - 1 );
					for ( var i : int = 0; i < _path._path.length; ++i )
					{
						_path._path[ i ] = potentialPath._path[ i ];
					}
				}
			}
			else
			{
				//square:
				if ( dimensions._width == dimensions._height )
				{
					//square objects which have some center tile:
					if ( dimensions._width % 2 == 1 )
					{
						_path = TryCenter(
							blisc,
							movingTemplate,
							from,
							blisc._aStar.grid.GetTileRealValued(
								to.GetTileX() + Math.floor( dimensions._width / 2.0 ),
								to.GetTileY() + Math.floor( dimensions._height / 2.0 ) ),
							Math.floor( dimensions._width / 2.0 ) + 1
						);
					}
					//square objects which, sadly, do not have any center: path must be found for each tile separately:
					else
					{
						_path = Iterate( blisc, movingTemplate, from, to, Math.max( dimensions._width, dimensions._height ) );
					}
				}
				//rectangular objects, surely, can be broken to smaller square ones and processed better, but it's in the other reality where deadlines are much farther:
				else
				{
					_path = Iterate( blisc, movingTemplate, from, to, Math.max( dimensions._width, dimensions._height ) );
				}
			}
		}
		
		/** For square objects with side > 1.
		\param within How deep center tile ("to") is within object. 0 if object is 1x1. It's the amount of tiles between center and outter world.
		\return null if wasn't found.
		*/
		private function TryCenter( blisc : Blisc, movingTemplate : BliscUnitTemplate, from : AStarNode, to : AStarNode, within : int ) : Path
		{
			//"closest" could be specified as "false" for 1x1 objects (and "endAsPassing" as "false" for ~1x1 objects) but we use this function for square objects with side > 1:
			var precisePath : Path = blisc._aStar.search( movingTemplate, from, to, Resources.SLIPPING_VALUE, true );
			if (	precisePath.last != null &&
					Math.abs( precisePath.last._tileX - to._tileX ) <= within &&
					Math.abs( precisePath.last._tileY - to._tileY ) <= within )
			{
				return precisePath;
				
				return result;
			}
			
			return null;
		}
		
		/**
		\param tooMuch Maximum amount of tiles closest tile can be far from each iterating tile to be possible for existing path.
		\return Path to some tile from specified dimensions or null if not a single path found (or guaranteed cannot be found if interrupted early).
		*/
		private function Iterate( blisc : Blisc, movingTemplate : BliscUnitTemplate, from : AStarNode, to : BliscCompound, tooMuch : int ) : Path
		{
			//to avoid multiple path findings for similar tiles:
			var touched : Vector.< AStarNode > = new Vector.< AStarNode >;
			
			var result : Path = null;
			
			for each ( var bcwc : BliscComplexWithinCompound in to._complexes )
			{
				//to cancel early:
				var stopIt : Boolean = false;
				
				bcwc._complex._bdo.ForEachAffectedTile( function( tile : AStarNode, region : BliscRegion ) : void
				{
					//if everything already finished:
					if ( result != null || stopIt )
					{
						return;
					}
					
					//checking if tile was already processed:
					for each ( var alreadyTouched : AStarNode in touched )
					{
						if ( tile == alreadyTouched )
						{
							return;
						}
					}
					
					touched.push( tile );
					
					var somePath : Path = blisc._aStar.search( movingTemplate, from, tile, Resources.SLIPPING_VALUE, false, true, null, false, true );
					if ( somePath._complete )
					{
						result = new Path( true, somePath._path.length - 1 );
						for ( var i : int = 0; i < result._path.length; ++i )
						{
							result._path[ i ] = somePath._path[ i ];
						}
					}
					else if ( somePath._closest == null )
					{
						Cc.error( "E: PathFinder.Iterate(): closest tile wasn't specified." );
						stopIt = true;
						return;
					}
					//if closest tile is too far away - path will not be found to any other target's tile as well:
					else
					{
						if ( Math.abs( somePath._closest._tileX - tile._tileX ) > tooMuch || Math.abs( somePath._closest._tileY - tile._tileY ) > tooMuch )
						{
							Cc.info( "I: PathFinder.Iterate(): too far." );
							stopIt = true;
							return;
						}
					}
				} );
				
				if ( result != null || stopIt )
				{
					return result;
				}
			}
			
			return result;
		}
		
		/** Null if wasn't found.*/
		public function get path() : Path
		{
			return _path;
		}
		
	}

}



