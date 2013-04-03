///@cond
package
{
	import project_data.CompoundTemplate;
	
	///@endcond
	
	
	/** Who depends on specified compound template.*/
	public class CompoundsDependence 
	{
		/** Dependence of which is presented here.*/
		public var _compound : CompoundTemplate;
		
		/** Instances within each dependent map. Independent maps are not presented here.*/
		public var _maps : Vector.< CompoundsMapDependence > = new Vector.< CompoundsMapDependence >;
		
		/** Sum of must-be-removed instances within all _maps.*/
		public var _instances : int = 0;
		
		
		public function CompoundsDependence( compound : CompoundTemplate )
		{
			_compound = compound;
		}
		
		
		
	}

}

