///@cond
package  
{
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import mx.controls.ToolTip;
	import mx.core.ISelectableList;
	import mx.core.IToolTip;
	import mx.core.UIComponent;
	import mx.managers.ToolTipManager;
	import project_data.Resource;
	import project_data.SingleResource;
	import utils.Utils;
	
	///@endcond
	
	/** Displays graphical part of a resources.*/
	public class ResourcesPreview extends UIComponent
	{
		private var _downPos:Point = new Point;
		private var _down:Boolean = false;
		
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		public static var _resourceTip:IToolTip = null;
		
		private var _previews:Vector.< SingleResourcePreview > = new Vector.< SingleResourcePreview >;
		
		
		public function ResourcesPreview()
		{
			//using scrollers instead of dragging:
			/*addEventListener( MouseEvent.MOUSE_DOWN, function( e:MouseEvent ): void
			{
				_downPos.x = e.stageX - x;
				_downPos.y = e.stageY - y;
				_down = true;
			} );
			addEventListener( MouseEvent.MOUSE_MOVE, function( e:MouseEvent ): void
			{
				if ( _down )
				{
					x = e.stageX - _downPos.x;
					y = e.stageY - _downPos.y;
					
					FitBounds();
				}
			} );
			addEventListener( MouseEvent.MOUSE_UP, function( e:MouseEvent ): void
			{
				_down = false;
			} );*/
		}
		
		public static function HideTip(): void
		{
			if ( _resourceTip != null )
			{
				ToolTipManager.destroyToolTip( _resourceTip );
				_resourceTip = null;
			}
		}
		
		private function FitBounds(): void
		{
			var bounds:Rectangle = getBounds( this );
			if ( x < -bounds.left )
			{
				x = -bounds.left
			}
			if ( y < -bounds.top )
			{
				y = -bounds.top;
			}
		}
		
		public function Display( resource:Resource, project:Project ): void
		{
			for each ( var singlePreview:SingleResourcePreview in _previews )
			{
				singlePreview.Destroy();
			}
			_previews.length = 0;
			Utils.RemoveAllChildren( this );
			
			const H_GAP:Number = 60;
			const V_GAP:Number = 20;
			
			_width = H_GAP;
			_height = V_GAP;
			
			
			for each ( var className:String in resource._names )
			{
				var singleResource:SingleResource = new SingleResource;
				singleResource.Init( resource._path, className );
				
				var view:DisplayObject = singleResource.Display( project );
				if ( view == null )
				{
					Cc.warn( "W: ResourcesPreview.Display(): \"" + singleResource._name + "\" is not graphical object. Skipping it." );
					continue;
				}
				
				const NAME_HEIGHT:Number = 20;
				const NAME_GAP:Number = 20;
				
				var name:TextField = new TextField;
				name.selectable = false;
				name.mouseEnabled = false;
				name.x = _width;
				name.y = V_GAP;
				var textFormat:TextFormat = name.defaultTextFormat;
				textFormat.size = 22;
				name.defaultTextFormat = textFormat;
				name.text = singleResource._name;
				name.filters = [ new GlowFilter( 0xffffff, 1, 3, 3, 10 ) ];
				
				view.x = _width;
				view.y = name.y + 10;
				addChild( view );
				
				addChild( name );
				
				_previews.push( new SingleResourcePreview( singleResource, view, project ) );
				
				_height = Math.max( _height, view.y + view.height );
				_width += Math.max( name.textWidth, view.width ) + H_GAP;
			}
			_height += V_GAP;
			
			/*graphics.clear();
			graphics.beginFill( 0x369E24 );
			graphics.drawRect( 0, 0, _width, _height );
			graphics.endFill();*/
			
			FitBounds();
			
			//if not to call this (or just call measure()) scroller will not draw scroll bars until you'll change application's size or grag VDividedBox a little:
			invalidateSize();
		}
		
		override protected function measure(): void
		{
			super.measure();
			
			measuredWidth = _width;
			measuredHeight = _height;
		}
	}

}


