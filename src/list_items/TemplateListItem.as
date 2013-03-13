package list_items 
{
	import project_data.ComplexTemplate;
	public class TemplateListItem extends Object
	{
		private var _label:String;
		private var _template:ComplexTemplate;
		
		
		public function TemplateListItem( label:String, template:ComplexTemplate ) 
		{
			_label = label;
			_template = template;
		}
		
		public function set label( value:String ): void
		{
			_label = value;
		}
		public function get label(): String
		{
			return _label;
		}
		
		public function set template( value:ComplexTemplate ): void
		{
			_template = value;
		}
		public function get template(): ComplexTemplate
		{
			return _template;
		}
		
	}

}

