///@cond
package  
{
	import project_data.Map;
	import project_data.ObjectInstance;
	
	///@endcond
	
	
	/** How map depends on specified template.*/
	public class TemplatesMapDependence 
	{
		public var _map : Map;
		
		public var _instances : Vector.< ObjectInstance > = new Vector.< ObjectInstance >;
		
		
		public function TemplatesMapDependence( map : Map )
		{
			_map = map;
		}
	}

}

