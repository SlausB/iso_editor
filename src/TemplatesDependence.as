///@cond
package  
{
	import project_data.ComplexTemplate;
	import project_data.CompoundTemplate;
	import project_data.ObjectInstance;
	
	///@endcond
	
	
	/** Who depends on specified complex template.*/
	public class TemplatesDependence
	{
		/** Dependence of which is presented here.*/
		public var _template : ComplexTemplate;
		
		/** Each dependent compound are presented once here even if template mentioned multiple times there.*/
		public var _compounds : Vector.< CompoundTemplate > = new Vector.< CompoundTemplate >;
		
		/** Instances within each dependent map. Independent maps are not presented here.*/
		public var _maps : Vector.< TemplatesMapDependence > = new Vector.< TemplatesMapDependence >;
		
		/** Sum of must-be-removed instances within all _maps.*/
		public var _instances : int = 0;
		
		
		public function TemplatesDependence( template : ComplexTemplate )
		{
			_template = template;
		}
	}

}

