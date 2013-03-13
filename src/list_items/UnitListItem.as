///@cond
package list_items 
{
	///@endcond
	
	
	public class UnitListItem
	{
		private var _label:String;
		private var _unit:UnitDesc;
		
		
		public function UnitListItem( label:String, unit:UnitDesc )
		{
			_label = label;
			_unit = unit;
		}
		
		public function set label( value:String ): void
		{
			_label = value;
		}
		public function get label(): String
		{
			return _label;
		}
		
		public function set unit( value:UnitDesc ): void
		{
			_unit = value;
		}
		public function get unit(): UnitDesc
		{
			return _unit;
		}
		
	}

}

