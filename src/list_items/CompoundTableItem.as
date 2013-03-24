///@cond
package list_items
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import project_data.ComplexTemplate;
	import project_data.ComplexWithinCompound;
	import project_data.CompoundTemplate;
	import project_data.Map;
	import project_data.ObjectInstance;
	import utils.Utils;
	
	///@endcond
	
	public class CompoundTableItem extends ListItem
	{
		private var _used:int;
		private var _view:Sprite = new Sprite;
		
		
		public function CompoundTableItem( compound:CompoundTemplate, main:Main )
		{
			super( compound );
			
			UpdateUsage( main );
			
			UpdateView( main );
		}
		
		public function set compound( value:CompoundTemplate ): void
		{
			super.data = value;
		}
		public function get compound(): CompoundTemplate
		{
			return super.data as CompoundTemplate;
		}
		
		
		public function get name(): String
		{
			return compound._name;
		}
		
		public function get used(): int
		{
			return _used;
		}
		public function UpdateUsage( main:Main ): void
		{
			var map:Map = main._isometry.displaying;
			
			_used = -1;
			
			if ( map != null )
			{
				_used = 0;
				
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
			
			var mediate:Sprite = new Sprite;
			var views:Vector.< ComplexView > = new Vector.< ComplexView >;
			
			for each ( var cwc:ComplexWithinCompound in compound._consisting )
			{
				var addingView:DisplayObject = cwc._complex._singleResource.Display( main._project );
				
				var addingPos:Point = Utils.FromIso( cwc._tileDispX * main._project.side, cwc._tileDispY * main._project.side, new Point );
				
				addingView.x = cwc._complex._disp.x + addingPos.x;
				addingView.y = cwc._complex._disp.y + addingPos.y;
				
				views.push( new ComplexView( addingView, main._project.ResolveLayerIndex( cwc._complex._layer ), addingPos.y + cwc._complex._center.y ) );
			}
			
			views.sort( function( lesser:ComplexView, greater:ComplexView ): int
			{
				if ( lesser._layerIndex < greater._layerIndex )
				{
					return -1;
				}
				if ( lesser._layerIndex == greater._layerIndex )
				{
					if ( lesser._yPos < greater._yPos )
					{
						return -1;
					}
					if ( lesser._yPos == greater._yPos )
					{
						return 0;
					}
					return 1;
				}
				return 1;
			} );
			
			for ( var displayingIndex:int = 0; displayingIndex < views.length; ++displayingIndex )
			{
				mediate.addChild( views[ displayingIndex ]._view );
			}
			
			const TARGET_SIZE:Number = 26;
			
			mediate.scaleX = mediate.scaleY = Math.min( TARGET_SIZE / mediate.width, TARGET_SIZE / mediate.height );
			
			_view.addChild( mediate );
		}
		
	}

}
import flash.display.DisplayObject;

class ComplexView
{
	public var _view:DisplayObject;
	public var _layerIndex:int;
	public var _yPos:Number;
	
	public function ComplexView( view:DisplayObject, layerIndex:int, yPos:Number )
	{
		_view = view;
		_layerIndex = layerIndex;
		_yPos = yPos;
	}
}

