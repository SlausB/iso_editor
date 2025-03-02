///@cond
package blisc.pathfinding 
{
	import blisc.core.BliscDisplayObject;
	import blisc.templates.BliscRegion;
	
	///@endcond
	
	
	/** Which surface or space was restriction within tile and why.*/
	public class Restriction 
	{
		/** Which surface or space restricted.*/
		public var _region : BliscRegion;
		
		/** Who covers this region.*/
		public var _bdo : BliscDisplayObject;
		
		
		public function Restriction( region : BliscRegion, bdo : BliscDisplayObject )
		{
			_region = region;
			_bdo = bdo;
		}
		
		public function Destroy() : void
		{
			_region = null;
			_bdo = null;
		}
		
	}

}

