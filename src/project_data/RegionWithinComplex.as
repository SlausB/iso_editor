///@cond
package project_data
{
	import flash.geom.Point;
	
	///@endcond
	
	
	/** Region specification for some complex template.*/
	public class RegionWithinComplex
	{
		/** Describing region.*/
		public var _region : Region;
		
		/** Relative tile coordinates of region's tiles.*/
		public var _tiles : Vector.< Point > = new Vector.< Point >;
		
		
		public function Init( region : Region ) : void
		{
			_region = region;
		}
		
		public function Clone() : RegionWithinComplex
		{
			var result : RegionWithinComplex = new RegionWithinComplex;
			
			result.Init( _region );
			
			for each ( var tile : Point in _tiles )
			{
				result._tiles.push( tile.clone() );
			}
			
			return result;
		}
	}

}

