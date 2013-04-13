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
		
		/** To represent it somehow while dragging from list view to isometry and generate Resources file.*/
		public var _singleResource : SingleResource;
		
		/** In the same order how views was specified within _template.*/
		public var _orientations : Vector.< UnitOrientation > = new Vector.< UnitOrientation >;
		
		
		public function UnitDesc( template : BliscUnitTemplate, singleResource : SingleResource )
		{
			_template = template;
			_singleResource = singleResource;
		}
	}

}

