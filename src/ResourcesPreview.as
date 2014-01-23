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
		/** Virtual dimensions of whole resources preview at least part of which is currently displayed.*/
		private var _width : Number = 0;
		private var _height : Number = 0;
		
		public static var _resourceTip : IToolTip = null;
		
		private var _previews : Vector.< SingleResourcePreview > = new Vector.< SingleResourcePreview >;
		
		/** Dimensions of scroller where at least part of everything is displayed.*/
		private var _scrollerWidth : Number = 0;
		private var _scrollerHeight : Number = 0;
		
		
		public static function HideTip() : void
		{
			if ( _resourceTip != null )
			{
				ToolTipManager.destroyToolTip( _resourceTip );
				_resourceTip = null;
			}
		}
		
		private function FitBounds() : void
		{
			var bounds : Rectangle = getBounds( this );
			if ( x < -bounds.left )
			{
				x = -bounds.left
			}
			if ( y < -bounds.top )
			{
				y = -bounds.top;
			}
		}
		
		private function Position() : void
		{
			const H_GAP : Number = 60;
			const V_GAP : Number = 20;
			
			//upper left corner coordinates of preview which will be added next:
			var xPos : Number = H_GAP;
			var yPos : Number = V_GAP;
			_width = 0;
			_height = 0;
			
			//height of currently forming row:
			var curHeight : Number = 0;
			
			
			for each ( var singleResourcePreview : SingleResourcePreview in _previews )
			{
				if ( ( xPos + 40 ) >= _scrollerWidth )
				{
					xPos = H_GAP;
					yPos += curHeight;
					curHeight = 0;
				}
				
				singleResourcePreview.x = xPos;
				singleResourcePreview.y = yPos;
				
				xPos += singleResourcePreview.width + H_GAP;
				
				curHeight = Math.max( singleResourcePreview.height + V_GAP, curHeight );
				
				_width = Math.max( xPos, _width );
				_height = Math.max( yPos + curHeight, _height );
			}
			
			FitBounds();
			
			//if not to call this (or just call measure()) scroller will not draw scroll bars until you'll change application's size or grag VDividedBox a little:
			invalidateSize();
		}
		
		public function Display( resource : Resource, project : Project ) : void
		{
			for each ( var singlePreview : SingleResourcePreview in _previews )
			{
				singlePreview.Destroy();
				if ( singlePreview.parent != null )
				{
					singlePreview.parent.removeChild( singlePreview );
				}
			}
			_previews.length = 0;
			Utils.RemoveAllChildren( this );
			
			for each ( var className : String in resource._names )
			{
				var singleResource : SingleResource = new SingleResource;
				singleResource.Init( resource._path, className );
				
				var view : DisplayObject = singleResource.Display( project );
				if ( view == null )
				{
					Cc.warn( "W: ResourcesPreview.Display(): \"" + singleResource._name + "\" is not graphical object. Skipping it." );
					continue;
				}
				
				var singleResourcePreview : SingleResourcePreview = new SingleResourcePreview( singleResource, project, view );
				addChild( singleResourcePreview );
				_previews.push( singleResourcePreview );
			}
			
			Position();
		}
		
		override protected function measure(): void
		{
			super.measure();
			
			measuredWidth = _width;
			measuredHeight = _height;
		}
		
		public function Resize( scrollerWidth:Number, scrollerHeight:Number ): void
		{
			_scrollerWidth = scrollerWidth;
			_scrollerHeight = scrollerHeight;
			
			Position();
		}
	}

}


