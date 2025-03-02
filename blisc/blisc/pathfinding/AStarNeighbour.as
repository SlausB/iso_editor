///@cond
package blisc.pathfinding
{
	
	///@endcond
	
	
	public class AStarNeighbour
	{
		/** Null if doesn't exist for specified orientation.*/
		public var _node : AStarNode;
		public var _orientation : int;
		
		
		public function AStarNeighbour( node : AStarNode, orientation : int )
		{
			_node = node;
			_orientation = orientation;
		}
		
	}

}

