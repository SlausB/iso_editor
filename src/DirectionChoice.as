///@cond
package
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import utils.Utils;
	
	///@endcond
	
	
	/** Unit walking orientation arrow used within EditingUnitWindow to allow designer refuse some directions which unit should NOT go.*/
	public class DirectionChoice extends Sprite
	{
		private var _orientation : int;
		private var _refusedState : Boolean;
		private var _up : DisplayObject;
		private var _over : DisplayObject;
		private var _refused : DisplayObject;
		private var _refusedOver : DisplayObject;
		
		private var _isOver : Boolean = false;
		
		
		/**
		\param refusedState True if initially should be refused.
		*/
		public function DirectionChoice( orientation : int, refusedState : Boolean, up : DisplayObject, over : DisplayObject, refused : DisplayObject, refusedOver : DisplayObject )
		{
			_orientation = orientation;
			_refusedState = refusedState;
			_up = up;
			_over = over;
			_refused = refused;
			_refusedOver = refusedOver;
			
			addChild( _up );
			addChild( _over );
			addChild( _refused );
			addChild( _refusedOver );
			
			addEventListener( MouseEvent.CLICK, function( e : MouseEvent ) : void
			{
				_refusedState = !_refusedState;
				Display();
			} );
			addEventListener( MouseEvent.MOUSE_OVER, function( e : MouseEvent ) : void
			{
				_isOver = true;
				Display();
			} );
			addEventListener( MouseEvent.MOUSE_OUT, function( ... args ) : void
			{
				_isOver = false;
				Display();
			} );
			
			Display();
		}
		
		public function get orientation() : int
		{
			return _orientation;
		}
		
		public function get refusedState() : Boolean
		{
			return _refusedState;
		}
		
		private function Display() : void
		{
			_up.visible = _isOver == false && _refusedState == false;
			_over.visible = _isOver && _refusedState == false;
			_refused.visible = _isOver == false && _refusedState;
			_refusedOver.visible = _isOver && _refusedState;
		}
		
	}

}

