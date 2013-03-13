///@cond
package list_items 
{
	import project_data.Map;
	///@endcond
	
	
	public class MapListItem 
	{
		private var _label:String;
		private var _map:Map;
		
		
		public function MapListItem( label:String, map:Map )
		{
			_label = label;
			_map = map;
		}
		
		public function set label( value:String ): void
		{
			_label = value;
		}
		public function get label(): String
		{
			return _label;
		}
		
		public function set map( value:Map ): void
		{
			_map = value;
		}
		public function get map(): Map
		{
			return _map;
		}
		
	}

}

