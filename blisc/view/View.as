///@cond
package view 
{
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	///@endcond
	
	/** How ordinary objects graphical representation incapsulation system must look.*/
	public class View 
	{
		/** Issued when mouse is hovered over an object. Next MOUSE_OVER is possible only after subsequent MOUSE_OUT.*/
		public static const MOUSE_OVER : int = 1;
		/** Issued when mouse is moved over an objects. Only issued between MOUSE_OVER and MOUSE_OUT and at least once there.*/
		public static const MOUSE_HOVER : int = 2;
		/** Issued when mouse was over an object but hovered out.*/
		public static const MOUSE_OUT : int = 3;
		/** Left mouse button pressed and released upon an object without dragging. Possible only after MOUSE_OVER and MOUSE_HOVER.*/
		public static const MOUSE_CLICK : int = 4;
		/** Left mouse button pressed and released on an empty area or upon objects which must not issue mouse events (ordinary used to sent currently selected unit, position object and something like that).*/
		public static const MOUSE_MISS : int = 5;
		
		protected var _viewport : DisplayObjectContainer;
		protected var _mouseHandler : Function;
		
		/**
		\param viewport Where everything will be displayed. Beware, this object is used directly, so it can be changed in size, something can be added on display list, something removed (or everything) and so on...
		\param mouseHandler function( type : int, opaqueData : * ) : void - where \b type is one of MOUSE_... constants and opaqueData is one specified within Viewable's constructor. If type is MOUSE_MISS then passing opaque data is Point object where mouse was clicked in planar coordinates.*/
		public function View( viewport : DisplayObjectContainer, mouseHandler : Function )
		{
			_viewport = viewport;
			_mouseHandler = mouseHandler;
		}
		
		/** Just create, don't add it somewhere or change yourself anyhow.*/
		public function CreateViewable( howItMustLook : DisplayObject, opaqueData : * ) : Viewable
		{
			Cc.error( "E: View.CreateViewable(): is abstract." );
			return null;
		}
		
		/** Added object will be able to be viewed.*/
		public function Add( what : Viewable ) : void
		{
			Cc.error( "E: View.Add(): is abstract." );
		}
		
		/** Don't show specified object anymore if it was.*/
		public function Remove( what : Viewable ) : void
		{
			Cc.error( "E: View.Remove(): is abstract." );
		}
		
		public function Destroy() : void
		{
		}
	}
	
}



