package blisc.pathfinding
{
	import blisc.templates.BliscUnitTemplate;
	import com.junkbyte.console.Cc;
	import flash.geom.Point;
	import iso.orient.Orientation;


	public class AStar
	{
		private var _openHeap : BinaryHeap = new BinaryHeap;
		private var _touched : Vector.< AStarNode >;
		private var _grid : Grid;
		
		
		/** Unit can walk on tile regardless default check.*/
		public static const OVERCHECK_ALLOW : int = 1;
		/** Unit CANNOT walk on tile regardless default check.*/
		public static const OVERCHECK_REFUSE : int = 2;
		/** Default check must be used.*/
		public static const OVERCHECK_DEFAULT : int = 3;
		
		
		/** .
		\param mapRight Distance from map's center to it's right and left borders.
		\param mapDown Distance from map's center to it's down and up borders.
		\param tileSize Distance from tile's center to it's right (east) corner.
		*/
		public function AStar( mapRight : Number, mapDown : Number, tileSize : Number, tileSide : Number )
		{
			_grid = new Grid( mapRight, mapDown, tileSize, tileSide );
			_touched = new Vector.< AStarNode >( _grid.tilesCount + 1, true );
		}
		
		public function get grid() : Grid
		{
			return _grid;
		}
		
		/** .
		\param slippingValue Maximum amoung of adjacent neighbour tiles unit can slip through when walking over tile's angle (north, east, south, west).
		\param closest True if need to find path to closest tile to destination one if path to it wasn't found.
		\param endAsPassing Set to true if ending tile must be assumed as tile unit can walk on (it it's non-null).
		\param overcheck function( node : AStarNode ) : int If not null, used to obtain one of OVERCHECK_... constants as redefined moving possibility resolving.
		\param startingAsWell True if starting tile must be checked for passability as well.
		\param closestTileNeeded True if closest tile must be passed to resulting path. If complete path will be found, null will be passed in any way.
		*/
		public function search(
			unit : BliscUnitTemplate,
			start : AStarNode,
			end : AStarNode,
			slippingValue : int,
			closest : Boolean = false,
			endAsPassing : Boolean = false,
			overcheck : Function = null,
			startingAsWell : Boolean = false,
			closestTileNeeded : Boolean = false
		) : Path
		{
			if ( start == null || end == null )
			{
				return null;
			}
			
			if ( start == end )
			{
				var shortPath : Path = new Path( true, 2 );
				shortPath._path[ 0 ] = start;
				shortPath._path[ 1 ] = end;
				return shortPath;
			}
			
			function CanWalk( overcheckingNode : AStarNode ) : Boolean
			{
				if ( overcheck == null )
				{
					return overcheckingNode.CanWalk( unit );
				}
				
				var overcheckResult : int;
				try
				{
					overcheckResult = overcheck( overcheckingNode );
				}
				catch ( e : Error )
				{
					Cc.error( "E: AStar.search(): CanWalk(): call to overcheck failed with \"" + e.message + "\"." );
					return overcheckingNode.CanWalk( unit );
				}
				
				if ( overcheckResult == OVERCHECK_DEFAULT )
				{
					return overcheckingNode.CanWalk( unit );
				}
				else if ( overcheckResult == OVERCHECK_ALLOW )
				{
					return true;
				}
				return false;
			};
			
			if ( startingAsWell && CanWalk( start ) == false )
			{
				return new Path( false, 0 );
			}
			
			var closestNode : AStarNode = start;
			var closestH : Number;
			if ( closest || closestTileNeeded )
			{
				closestH = heuristic( closestNode._tileX, closestNode._tileY, end._tileX, end._tileY );
			}
			
			//clean up all previously changed data:
			for ( var cleaning : int = 0; cleaning < _touched.length; ++cleaning )
			{
				var touched : AStarNode = _touched[ cleaning ];
				if ( touched == null )
				{
					break;
				}
				
				touched._f = 0;
				touched._g = 0;
				touched._h = 0;
				touched._closed = false;
				touched._visited = false;
				touched._previous = null;
				touched._next = null;
				_touched[ cleaning ] = null;
			}
			_openHeap.reset();
			
			
			_openHeap.push( start );
			
			
			var i : int = 0;
			while ( _openHeap.size > 0 )
			{
				var currentNode : AStarNode = _openHeap.pop();
				
				//if path found:
				if ( currentNode == end )
				{
					i = 0;
					while ( currentNode._previous )
					{
						currentNode._previous._next = currentNode;
						++i;
						currentNode = currentNode._previous;
					}
					var result : Path = new Path( true, i + 1 );
					for ( var j : int = 0; currentNode != null; ++j )
					{
						result._path[ j ] = currentNode;
						currentNode = currentNode._next;
					}
					return result;
				}
				
				if ( closest || closestTileNeeded )
				{
					if ( currentNode != closestNode )
					{
						var newClosestH : Number = heuristic( currentNode._tileX, currentNode._tileY, end._tileX, end._tileY );
						if ( newClosestH < closestH )
						{
							closestNode = currentNode;
							closestH = newClosestH;
						}
					}
				}
				
				currentNode._closed = true;
				if ( i >= _touched.length )
				{
					break;
				}
				_touched[ i++ ] = currentNode;
				
				var doBreak : Boolean = false;
				
				for ( var neighborIndex : int = 0; neighborIndex < currentNode._neighbors.length; ++neighborIndex )
				{
					//checking if unit CAN go current direction:
					var refused : Boolean = false;
					for each ( var refusedDirection : int in unit._refusedDirections )
					{
						if ( refusedDirection == neighborIndex )
						{
							refused = true;
							break;
						}
					}
					if ( refused )
					{
						continue;
					}
					
					var neighbor : AStarNeighbour = currentNode._neighbors[ neighborIndex ];
					
					if (
						//out of maps borders:
						neighbor._node == null ||
						//already faced:
						neighbor._node._closed ||
						//cannot walk upon and not ending tile which must be assumes as free to stand at:
						( ( endAsPassing && neighbor._node == end ) == false && CanWalk( neighbor._node ) == false )
					)
					{
						continue;
					}
					
					//checking slipping possibility for angle tiles:
					if ( slippingValue > 0 && neighborIndex % 2 == 0 )
					{
						var leftIsObstacle : Boolean = false;
						const leftIndex : int = ( neighborIndex + 7 ) % 8;
						if (	leftIndex >= currentNode._neighbors.length ||
								currentNode._neighbors[ leftIndex ]._node == null ||
								CanWalk( currentNode._neighbors[ leftIndex ]._node ) == false )
						{
							//if both neighbors was requested to be passable - this one is not so it doesn't matter what's up with second:
							if ( slippingValue > 1 )
							{
								continue;
							}
							
							leftIsObstacle = true;
						}
						
						const rightIndex : int = ( neighborIndex + 1 ) % 8;
						if (	rightIndex >= currentNode._neighbors.length ||
								currentNode._neighbors[ rightIndex ]._node == null ||
								CanWalk( currentNode._neighbors[ rightIndex ]._node ) == false )
						{
							if ( slippingValue > 1 )
							{
								continue;
							}
							//slipping value is 1 so left neighbor must be passable then:
							else if ( leftIsObstacle )
							{
								continue;
							}
						}
					}
					
					const newG : Number = currentNode._g + /*currentNode._cost*/heuristic( currentNode._tileX, currentNode._tileY, neighbor._node._tileX, neighbor._node._tileY );
					
					if ( neighbor._node._visited == false )
					{
						if ( i >= _touched.length )
						{
							doBreak = true;
							break;
						}
						_touched[ i++ ] = neighbor._node;
						
						neighbor._node._visited = true;
						neighbor._node._previous = currentNode;
						neighbor._node._g = newG;
						neighbor._node._h = heuristic( neighbor._node._tileX, neighbor._node._tileY, end._tileX, end._tileY );
						neighbor._node._f = newG + neighbor._node._h;
						_openHeap.push( neighbor._node );
					}
					else if ( newG < neighbor._node._g )
					{
						neighbor._node._previous = currentNode;
						neighbor._node._g = newG;
						const previousValue : Number = neighbor._node._f;
						neighbor._node._f = newG + neighbor._node._h;
						
						_openHeap.rescoreElement( neighbor._node, previousValue );
					}
				}
				
				if ( doBreak )
				{
					break;
				}
			}
			
			if ( closest )
			{
				if ( closestNode == start )
				{
					var weirdPath : Path = new Path( false, 2 );
					weirdPath._path[ 0 ] = start;
					weirdPath._path[ 1 ] = start;
					return weirdPath;
				}
				else
				{
					var incompleteResult : Path = search( unit, start, closestNode, slippingValue );
					incompleteResult._complete = false;
					return incompleteResult;
				}
			}
			return new Path( false, 0, closestTileNeeded ? closestNode : null );
		}
		
		private function heuristic( x1 : Number, y1 : Number, x2 : Number, y2 : Number ) : Number
		{
			//uncomment this later as part of new introducing zigzags avoidance complex:
			/*//trying to avoid zigzags:
			return Math.abs( x2 - x1 ) + Math.abs( y2 - y1 );*/
			
			const dx : Number = x2 - x1;
			const dy : Number = y2 - y1;
			return Math.sqrt( dx * dx + dy * dy );
		}
		
	}
}

