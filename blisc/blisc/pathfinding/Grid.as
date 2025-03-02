///@cond
package blisc.pathfinding 
{
	import com.junkbyte.console.Cc;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import iso.orient.Orientation;
	import utils.Utils;
	
	///@endcond
	
	
	/** Tiles layout. Each node has references to it's neighbours.*/
	public class Grid
	{
		private var _tilesCount : int = 0;
		
		private var _grid : Vector.< Vector.< AStarNode > > = new Vector.< Vector.< AStarNode > >;
		
		/** Zero tile's index on both axis within _grid array.*/
		private var _center : int;
		
		private var _side : int;
		
		
		public function get grid() : Vector.< Vector.< AStarNode > >
		{
			return _grid;
		}
		
		public function Grid( mapRight : Number, mapDown : Number, tileSize : Number, tileSide : Number )
		{
			//forming tiles grid from upper corner in a diamond form absorbing whole map's rectangle...
			
			//where it is need to start iterating in a diamond area to consume whole rectangular area:
			var startY : Number = -mapDown - mapRight / 2.0;
			
			_center = Math.abs( Math.ceil( startY / tileSize ) );
			_side = _center * 2;
			//correct using ceiled value:
			startY = -_center * tileSize;
			
			var viewport : Rectangle = new Rectangle( -mapRight, -mapDown, mapRight * 2, mapDown * 2 );
			var tilePos : Point = new Point;
			var tileRectangle : Rectangle = new Rectangle;
			
			for ( var x : int = 0; x < _side; ++x )
			{
				//ok, let's suppose the row is line connecting north and west:
				var row : Vector.< AStarNode > = new Vector.< AStarNode >;
				
				for ( var y : int = 0; y < _side; ++y )
				{
					Utils.FromIso( tileSide * x, tileSide * y, tilePos );
					
					tileRectangle.x = tilePos.x - tileSize;
					tileRectangle.y = startY + tilePos.y;
					tileRectangle.width = tileSize * 2;
					tileRectangle.height = tileSize;
					if ( viewport.intersects( tileRectangle ) )
					{
						row.push( new AStarNode( x - _center, y - _center ) );
						++_tilesCount;
					}
					else
					{
						row.push( null );
					}
				}
				
				_grid.push( row );
			}
			
			//applying neighbours:
			for ( var nx : int = -_center; nx < _center; ++nx )
			{
				for ( var ny : int = -_center; ny < _center; ++ny )
				{
					var tile : AStarNode = GetTile( nx, ny, false );
					if ( tile == null )
					{
						continue;
					}
					
					//north:
					AddNeighbour( tile, nx - 1, ny - 1, Orientation.N );
					//north east:
					AddNeighbour( tile, nx, ny - 1, Orientation.NE );
					//east:
					AddNeighbour( tile, nx + 1, ny -1, Orientation.E );
					//south east:
					AddNeighbour( tile, nx + 1, ny, Orientation.SE );
					//south:
					AddNeighbour( tile, nx + 1, ny + 1, Orientation.S );
					//south west:
					AddNeighbour( tile, nx, ny + 1, Orientation.SW );
					//west:
					AddNeighbour( tile, nx - 1, ny + 1, Orientation.W );
					//north west:
					AddNeighbour( tile, nx - 1, ny, Orientation.NW );
				}
			}
		}
		
		private function AddNeighbour( tile : AStarNode, x : int, y : int, orientation : int ): void
		{
			var neighbour : AStarNode = GetTile( x, y, false );
			
			//yeah, neighbour can be null:
			var nn : AStarNeighbour = new AStarNeighbour( neighbour, orientation );
			
			tile._neighbors.push( nn );
		}
		
		/** How much walkable tiles there are (tiles within ≈visible area).*/
		public function get tilesCount() : int
		{
			return _tilesCount;
		}
		
		/** With proper real-valued coordinates handling.*/
		public function GetTileRealValued( tileX : Number, tileY : Number, showError : Boolean = true ) : AStarNode
		{
			//sadly, objects coordinates are stored as simple isometric what causes to divide it at tileSide to get tile coordinate which leads to coords with pretty big fraction part: 0.00001 -> 0.01:
			//surely, coordinates like 2.999999 should be treaten as 3, not 2 (so, flooring isn't the choice), but coordinates like 2.5 should be rounded to 2 (well, all coords which less than 2.99999 should be "rounded" to 2):
			/*//rounding is actually the right thing:
			//return _blisc._aStar.grid.GetTile( Math.floor( GetTileX() ), Math.floor( GetTileY() ) );
			return _blisc._aStar.grid.GetTile( Math.round( GetTileX() ), Math.round( GetTileY() ) );*/
			const EPSILON : Number = 0.01;
			return GetTile( Math.floor( tileX + EPSILON ), Math.floor( tileY + EPSILON ) );
		}
		
		public function GetTile( tileX : int, tileY : int, showError : Boolean = true ) : AStarNode
		{
			if ( tileX < -_center || ( tileX + _center ) >= _grid.length )
			{
				if ( showError )
				{
					Cc.error( "E: Grid.GetTile(): tileX = " + tileX.toString() + " is wrong. Can be >= " + ( -_center).toString() + " and < " + _center.toString() + ". Returning null." );
				}
				return null;
			}
			
			var row : Vector.< AStarNode > = _grid[ tileX + _center ];
			if ( tileY < -_center || ( tileY + _center ) >= _grid.length )
			{
				if ( showError )
				{
					Cc.error( "E: Grid.GetTile(): tileY = " + tileY.toString() + " is wrong. Can be >= " + ( _center).toString() + " and < " + _center.toString() + ". Returning null." );
				}
				return null;
			}
			
			return row[ tileY + _center ];
		}
		
	}

}

