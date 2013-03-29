///@cond
package ie
{
	import list_items.ListItem;
	import project_data.Region;
	
	///@endcond
	
	
	/** Region within EditingTemplateWindow's drop down list.*/
	public class RegionChoiceListItem extends ListItem
	{
		public function RegionChoiceListItem( region:Region )
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

