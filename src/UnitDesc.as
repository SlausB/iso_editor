///@cond
package  
{
	import project_data.SingleResource;
	
	///@endcond
	
	/** Formed description of identified unit.*/
	public class UnitDesc 
	{
		public var _name:String;
		
		/** Just do represent it somehow while dragging from list view to isometry.*/
		public var _singleResource:SingleResource;
		
		public var _views:Vector.< UnitView > = new Vector.< UnitView >;
		
		
		public function UnitDesc( name:String, singleResource:SingleResource )
		{
			_name = name;
			_singleResource = singleResource;
		}
	}

}

