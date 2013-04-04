///@cond
package  
{
	import blisc.BliscAnimation;
	import blisc.templates.BliscUnitTemplate;
	import iso.orient.Orientation;
	import project_data.SingleResource;
	import utils.Utils;
	
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

