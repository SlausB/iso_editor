///@cond
package list_items
{
	import project_data.Region;
	
	///@endcond
	
	
	public class RegionListItem extends ListItem
	{
		
		public function RegionListItem( region:Region )
		{
			super( region );
		}
		
		public function get region(): Region
		{
			return _data as Region;
		}
		
		public function get label(): String
		{
			return region._name;
		}
		
		public function get name(): String
		{
			return region._name;
		}
		
	}

}

