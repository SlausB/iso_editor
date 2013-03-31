///@cond
package project_data
{
	
	///@endcond
	
	
	/** Properties designer managed to specify for that unit.*/
	public class UnitProperties
	{
		/** Unit's resource name. Yes - multiple units can have similar name - designer's drawback.*/
		public var _unit:String;
		
		/** Chosen default region. Null if wasn't yet.*/
		public var _region:Region = null;
		
		
		public function Init( unit:String ): void
		{
			_unit = unit;
		}
	}

}

