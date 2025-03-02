///@cond
package blisc.templates 
{
	import flash.geom.Point;
	
	///@endcond
	
	
	/** Region description for specific complex.
	\sa BliscRegion .*/
	public class BliscRegionWithinComplex
	{
		public var _region : BliscRegion;
		
		/** Logic tile coordinates of tiles which form this region.*/
		public var _tiles : Vector.< Point > = new Vector.< Point >;
		
		
		public function BliscRegionWithinComplex( region : BliscRegion, tiles : Vector.< Point > )
		{
			_region = region;
			_tiles = tiles;
		}
		
	}

}

