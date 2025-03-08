///@cond
package project_data
{
	
	///@endcond
	
	
	/** Properties designer managed to specify for that unit.*/
	public class UnitProperties
	{
		/** Unit's resource name. Yes - multiple units can have similar names - design flaw.*/
		public var _unit : String;
		
		/** Archaic field to avoid AMF loading errors/warning. Used to store chosen default region. Null if wasn't yet.*/
		public var _region : Region = null;
		
		/** Surfaces designer managed to choose for this unit - where it's walking upon.*/
		public var _surfaces : Vector.< Region > = new Vector.< Region >;
		
		/** Which directions unit cannot go.*/
		public var _refusedDirections : Vector.< int > = new Vector.< int >;
		
		
		public function Init( unit : String ) : void
		{
			_unit = unit;
		}
	}

}

