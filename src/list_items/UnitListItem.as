///@cond
package list_items
{
	///@endcond
	
	
	public class UnitListItem
	{
		private var _unit : UnitDesc;
		
		
		public function UnitListItem( unit : UnitDesc )
		{
			_unit = unit;
		}
		
		public function get label() : String
		{
			return unit._singleResource._name;
		}
		
		public function set unit( value : UnitDesc ) : void
		{
			_unit = value;
		}
		public function get unit() : UnitDesc
		{
			return _unit;
		}
		
	}

}

