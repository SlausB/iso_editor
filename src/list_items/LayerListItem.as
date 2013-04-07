///@cond
package list_items 
{
	import project_data.Layer;
	
	///@endcond
	
	
	public class LayerListItem extends Object
	{
		private var _label:String;
		private var _layer:Layer;
		private var _index:int;
		
		
		public function LayerListItem( label : String, layer : Layer, index : int ) 
		{
			_label = label;
			_layer = layer;
			_index = index;
		}
		
		public function set label( value:String ): void
		{
			_label = value;
		}
		public function get label(): String
		{
			return _label;
		}
		
		public function set layer( value:Layer ): void
		{
			_layer = value;
		}
		public function get layer(): Layer
		{
			return _layer;
		}
		
		public function set index( value:int ): void
		{
			_index = value;
		}
		public function get index(): int
		{
			return _index;
		}
		
		public function Destroy(): void
		{
			_layer = null;
		}
		
	}

}

