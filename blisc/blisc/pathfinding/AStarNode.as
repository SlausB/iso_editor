///@cond
package blisc.pathfinding
{
	import blisc.core.BliscDisplayObject;
	import blisc.instances.BliscComplex;
	import blisc.templates.BliscRegion;
	import blisc.templates.BliscUnitTemplate;
	
	///@endcond
	
	
	/** Single path-finding element - tile or something like that.*/
	public class AStarNode
	{
		public var _h : Number = 0;
		public var _f : Number = 0;
		public var _g : Number = 0;
		/** How hard it is to go over this node.*/
		public var _cost : uint = 0;
		public var _visited : Boolean = false;
		public var _closed : Boolean = false;
		
		/** Index within binary heap's array to speed up the search.*/
		public var _index : int = -1;
		
		/** Previous element within returning (found) path.*/
		public var _previous : AStarNode = null;
		/** Next node within found path (closer to destination).*/
		public var _next : AStarNode = null;
		/** Nodes adfacent to this one.*/
		public var _neighbors : Vector.< AStarNeighbour > = new Vector.< AStarNeighbour >;
		
		/** Both space and surface restrictions. Use AddRestriction() and RemoveRestriction() functions to modify this array.*/
		public var _restrictions : Vector.< Restriction > = new Vector.< Restriction >;
		
		public var _tileX : int;
		public var _tileY : int;
		
		
		public function AStarNode( tileX : int, tileY : int, cost : uint = 0 )
		{
			_tileX = tileX;
			_tileY = tileY;
			_cost = cost;
		}
		
		public function AddRestriction( owner : BliscDisplayObject, region : BliscRegion ): void
		{
			_restrictions.push( new Restriction( region, owner ) );
			
			SortRestrictions();
		}
		
		public function RemoveRestrictions( owner : BliscDisplayObject ) : void
		{
			var changed : Boolean = false;
			
			for ( var i : int = _restrictions.length - 1; i >= 0; --i )
			{
				var restriction : Restriction = _restrictions[ i ];
				if ( restriction._bdo == owner )
				{
					_restrictions.splice( i, 1 );
					restriction.Destroy();
					
					changed = true;
				}
			}
			
			if ( changed )
			{
				SortRestrictions();
			}
		}
		
		private function SortRestrictions() : void
		{
			_restrictions.sort( function( lesser : Restriction, greater : Restriction ) : Number
			{
				if ( lesser._bdo._layer._index < greater._bdo._layer._index )
				{
					return -1;
				}
				if ( lesser._bdo._layer._index > greater._bdo._layer._index )
				{
					return 1;
				}
				
				if ( lesser._bdo._sortVal < greater._bdo._sortVal )
				{
					return -1;
				}
				if ( lesser._bdo._sortVal == greater._bdo._sortVal )
				{
					return 0;
				}
				return 1;
			} );
		}
		
		/** Null if something is wrong.*/
		public function get highest() : Restriction
		{
			for ( var lookingSurfaceIndex : int = _restrictions.length - 1; lookingSurfaceIndex >= 0; --lookingSurfaceIndex )
			{
				var restriction : Restriction = _restrictions[ lookingSurfaceIndex ];
				if ( restriction._region._type == BliscRegion.TYPE_SURFACE )
				{
					return restriction;
				}
			}
			
			return null;
		}
		
		public function CanWalk( unit : BliscUnitTemplate ) : Boolean
		{
			if ( _restrictions.length <= 0 || unit._surfaces.length <= 0 )
			{
				return true;
			}
			
			//unit must compare itself only with highest visible object within tile:
			var tHighest : Restriction = highest;
			if ( tHighest == null )
			{
				return true;
			}
			
			for each ( var surface : BliscRegion in unit._surfaces )
			{
				if ( tHighest._region == surface )
				{
					return false;
				}
			}
			
			return true;
		}
		
		/** Returns false if specified space cannot be put on this tile.*/
		public function CanPutOn( space : BliscRegion ) : Boolean
		{
			if ( _restrictions.length <= 0 )
			{
				return true;
			}
			
			//we're putting only upon highest drawn object:
			//each object can have multiple specified spaces so we need to check all:
			var highestComplex : BliscComplex = _restrictions[ _restrictions.length - 1 ]._bdo._complex;
			for ( var lookingSpaceIndex : int = _restrictions.length - 1; lookingSpaceIndex >= 0; --lookingSpaceIndex )
			{
				var restriction : Restriction = _restrictions[ lookingSpaceIndex ];
				if ( restriction._region._type != BliscRegion.TYPE_SPACE )
				{
					continue;
				}
				
				//iterated till next (covered - not visible) object:
				if ( restriction._bdo._complex != highestComplex )
				{
					return true;
				}
				
				if ( restriction._region == space )
				{
					return false;
				}
			}
			return true;
		}
	}
}

