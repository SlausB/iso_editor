///@cond
package list_items
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import project_data.ComplexTemplate;
	import project_data.ComplexWithinCompound;
	import project_data.CompoundTemplate;
	import project_data.Map;
	import project_data.ObjectInstance;
	import project_data.ObjectTemplate;
	import utils.Utils;
	
	///@endcond
	
	
	public class TemplateTableItem extends ListItem
	{
		private var _used:int;
		private var _view:Sprite = new Sprite;
		
		
		public function TemplateTableItem( template:ComplexTemplate, main:Main ) 
		{
			super( template );
			
			UpdateUsage( main );
			
			UpdateView( main );
		}
		
		public function get template(): ComplexTemplate
		{
			return _data as ComplexTemplate;
		}
		
		public function get name(): String
		{
			return template._name;
		}
		
		public function get used(): int
		{
			return _used;
		}
		public function UpdateUsage( main:Main ): void
		{
			_used = 0;
			
			for each ( var object:ObjectTemplate in main._project._data._objects )
			{
				var compound:CompoundTemplate = object as CompoundTemplate;
				if ( compound == null )
				{
					continue;
				}
				
				for each ( var consisting:ComplexWithinCompound in compound._consisting )
				{
					if ( consisting._complex == _data )
					{
						++_used;
						break;
					}
				}
			}
			
			for each ( var map:Map in main._project._data._maps )
			{
				for each ( var objectInstance:ObjectInstance in map._instances )
				{
					if ( objectInstance._template == _data )
					{
						++_used;
					}
				}
			}
		}
		
		public function get view(): DisplayObject
		{
			return _view;
		}
		public function UpdateView( main:Main ): void
		{
			Utils.RemoveAllChildren( _view );
			
			if ( template._singleResource == null )
			{
				return;
			}
			
			var addingView:DisplayObject = template._singleResource.Display( main._project );
			addingView.x = template._disp.x;
			addingView.y = template._disp.y;
			
			const TARGET_SIZE:Number = 26;
			
			addingView.scaleX = addingView.scaleY = Math.min( TARGET_SIZE / addingView.width, TARGET_SIZE / addingView.height );
			
			_view.addChild( addingView );
		}
	}

}

