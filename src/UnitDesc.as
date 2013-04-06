///@cond
package  
{
	import blisc.templates.BliscUnitTemplate;
	import project_data.SingleResource;
	
	///@endcond
	
	/** Formed description of identified unit.*/
	public class UnitDesc 
	{
		public var _template : BliscUnitTemplate;
		
		/** Just to represent it somehow while dragging from list view to isometry.*/
		public var _singleResource:SingleResource;
		
		
		public function UnitDesc( template : BliscUnitTemplate, singleResource : SingleResource )
		{
			_template = template;
			_singleResource = singleResource;
		}
	}

}

