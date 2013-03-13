///@cond
package list_items 
{
	import project_data.Resource;
	
	///@endcond
	
	public class ResourceListItem 
	{
		public var _label:String;
		public var _resource:Resource;
		
		
		public function ResourceListItem( label:String, resource:Resource )
		{
			_label = label;
			_resource = resource;
		}
		
		public function set label( value:String ): void
		{
			_label = value;
		}
		public function get label(): String
		{
			return _label;
		}
		
		public function set resource( value:Resource ): void
		{
			_resource = value;
		}
		public function get resource(): Resource
		{
			return _resource;
		}
		
	}

}

