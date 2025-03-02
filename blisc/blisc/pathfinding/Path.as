///@cond
package blisc.pathfinding
{
	
	///@endcond
	
	
	/** Information about found path and how he was found.*/
	public class Path
	{
		/** True if path till requested tile (including it) found or false if wasn't found or found till closest tile if "closest" was specified.*/
		public var _complete : Boolean;
		
		/** Path from (including) starting tile to (including) destination tile if path was found or till closest tile if "closest" was specified. Otherwise has nothing.*/
		public var _path : Vector.< AStarNode >;
		
		/** Closest node to destination unit can walk to. Non-null if closestTileNeeded was specified as true while pathfinding AND closest as false and complete path cannot be found.*/
		public var _closest : AStarNode = null;
		
		
		public function Path( complete : Boolean, length : int, closest : AStarNode = null )
		{
			_complete = complete;
			_path = new Vector.< AStarNode >( length, true );
			_closest = closest;
		}
		
		public function Destroy() : void
		{
			//cannot change length... maybe because "fixed" was specified to true at creation:
			//_path.length = 0;
			_path = null;
		}
		
		public function get last() : AStarNode
		{
			if ( _path == null || _path.length < 1 )
			{
				return null;
			}
			return _path[ _path.length - 1 ];
		}
	}

}



