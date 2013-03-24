///@cond
package list_items
{
	import project_data.CompoundTemplate;
	
	///@endcond
	
	public class CompoundTableItem extends Object
	{
		private var _compound:CompoundTemplate;
		
		
		public function CompoundTableItem( compound:CompoundTemplate ) 
		{
			_label = label;
			_compound = compound;
		}
		
		public function set label( value:String ): void
		{
			_label = value;
		}
		public function get label(): String
		{
			return _label;
		}
		
		public function set compound( value:CompoundTemplate ): void
		{
			_compound = value;
		}
		public function get compound(): CompoundTemplate
		{
			return _compound;
		}
		
	}

}

