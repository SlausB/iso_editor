///@cond
package  
{
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import mx.managers.ToolTipManager;
	import project_data.SingleResource;
	import utils.Utils;
	
	///@endcond
	
	
	public class SingleResourcePreview extends Sprite
	{
		public var _singleResource:SingleResource;
		public var _project:Project;
		
		/** Sum dimentions of name, preview and possible highlight.*/
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		/** Gap between object's view and it's highlighting border.*/
		private static const BORDER_GAP:Number = 10;
		private var _border:Rectangle = new Rectangle;
		
		
		public function SingleResourcePreview( singleResource:SingleResource, project:Project, view:DisplayObject )
		{
			_singleResource = singleResource;
			_project = project;
			
			addChild( view );
			
			const NAME_HEIGHT:Number = 40;
			
			//caption:
			var name:TextField = new TextField;
			name.selectable = false;
			name.mouseEnabled = false;
			var textFormat:TextFormat = name.defaultTextFormat;
			textFormat.size = 22;
			name.defaultTextFormat = textFormat;
			name.text = singleResource._name;
			name.filters = [ new GlowFilter( 0xffffff, 1, 3, 3, 10 ) ];
			name.width = name.textWidth + 20;
			addChild( name );
			_height += name.height;
			
			//resource preview:
			var bounds:Rectangle = view.getRect( view );
			view.x = BORDER_GAP - bounds.x;
			view.y = BORDER_GAP + NAME_HEIGHT - bounds.y;
			_border.y = NAME_HEIGHT;
			_border.width = bounds.width + BORDER_GAP * 2;
			_border.height = bounds.height + BORDER_GAP * 2;
			_height += bounds.height + BORDER_GAP * 2;
			
			_width = Math.max( name.width, bounds.width + BORDER_GAP * 2 );
			
			
			addEventListener( MouseEvent.MOUSE_OVER, OnOver );
			addEventListener( MouseEvent.MOUSE_OUT, OnOut );
			addEventListener( MouseEvent.MOUSE_DOWN, OnDown );
		}
		
		public function Destroy(): void
		{
			removeEventListener( MouseEvent.MOUSE_OVER, OnOver );
			removeEventListener( MouseEvent.MOUSE_OUT, OnOut );
			removeEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			
			_singleResource = null;
			_project = null;
			
			Utils.RemoveAllChildren( this );
		}
		
		private function OnOver( ... args ): void
		{
			graphics.clear();
			graphics.lineStyle( 4, 0x44C97C );
			graphics.drawRect( _border.x, _border.y, _border.width, _border.height );
			
			ResourcesPreview.HideTip();
			ResourcesPreview._resourceTip = ToolTipManager.createToolTip( '"' + _singleResource._name + '". Drag and drop it to template editing window.', stage.mouseX, stage.mouseY );
		}
		
		private function OnOut( ... args ): void
		{
			graphics.clear();
			
			ResourcesPreview.HideTip();
		}
		
		private function OnDown( event:MouseEvent ): void
		{
			Main.StartDrag( event, _singleResource, Global.DRAG_FORMAT_SINGLE_RESOURCE, _singleResource.FindClass( _project ) );
		}
		
		override public function get width(): Number
		{
			return _width;
		}
		
		override public function set width( value:Number ): void
		{
			Cc.error( "E: SingleResourcePreview.set width(): meaningless." );
		}
		
		override public function get height(): Number
		{
			return _height;
		}
		
		override public function set height( value:Number ): void
		{
			Cc.error( "E: SingleResourcePreview.set height(): meaningless." );
		}
	}

}


