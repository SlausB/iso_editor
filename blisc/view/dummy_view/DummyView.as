///@cond
package view.dummy_view 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import utils.Utils;
	import view.Projection;
	import view.View;
	import view.Viewable;
	
	///@endcond
	
	/** Just the simplest graphics representation system possible.*/
	public class DummyView extends View
	{
		/** Which objects was hovered within previous mouse move.*/
		private var _currentOver:Vector.< DummyViewable > = new Vector.< DummyViewable >;
		
		/** Objects upon which mouse was clicked but not released yet.*/
		private var _mouseDown:Vector.< DummyViewable > = new Vector.< DummyViewable >;
		
		private var _mousePos:Point = new Point;
		
		
		public function DummyView( viewport:DisplayObjectContainer, mouseHandler:Function, projection:Projection )
		{
			super( viewport, mouseHandler, projection );
			
			_viewport.stage.addEventListener( MouseEvent.MOUSE_MOVE, OnMouseMove );
			_viewport.stage.addEventListener( MouseEvent.MOUSE_DOWN, OnMouseDown );
			_viewport.stage.addEventListener( MouseEvent.MOUSE_UP, OnMouseUp );
		}
		
		/**
		\param howItMustLook Only objects of class Bitmap or higher.*/
		override public function CreateViewable( howItMustLook:DisplayObject, opaqueData:* ): Viewable
		{
			return new DummyViewable( howItMustLook as Bitmap, opaqueData, _projection );
		}
		
		override public function Add( what:Viewable ): void
		{
			_viewport.addChild( what as DummyViewable );
		}
		
		override public function Remove( what:Viewable ): void
		{
			try
			{
				_viewport.removeChild( what as DummyViewable );
			}
			catch ( e:* )
			{
			}
		}
		
		override public function Destroy(): void
		{
			_viewport.stage.removeEventListener( MouseEvent.MOUSE_MOVE, OnMouseMove );
			_viewport.stage.removeEventListener( MouseEvent.MOUSE_DOWN, OnMouseDown );
			_viewport.stage.removeEventListener( MouseEvent.MOUSE_UP, OnMouseUp );
			
			Utils.RemoveAllChildren( _viewport );
		}
		
		private function AsDummyViewable( something:*, x:Number, y:Number ): DummyViewable
		{
			var displayObject:DisplayObject = something as DisplayObject;
			while ( displayObject != null )
			{
				if ( displayObject is DummyViewable )
				{
					var dv:DummyViewable = displayObject as DummyViewable;
					var local:Point = dv._howItLooks.globalToLocal( new Point( x, y ) );
					//doesn't work if to embed the "... >> ..." sentence right within if() (evern within brackets):
					const alpha:uint = dv._howItLooks.bitmapData.getPixel32( local.x, local.y ) >> 24;
					if ( alpha > 0 )
					{
						return dv;
					}
					return null;
				}
				
				displayObject = displayObject.parent;
			}
			
			return null;
		}
		
		private function OnMouseMove( e:MouseEvent ): void
		{
			_mousePos.x = e.localX;
			_mousePos.y = e.localY;
			
			var newOver:Vector.< DummyViewable > = new Vector.< DummyViewable >;
			
			var objectsUnderPoint:Array = _viewport.getObjectsUnderPoint( _mousePos );
			for each ( var something:* in objectsUnderPoint )
			{
				var dummyViewable:DummyViewable = AsDummyViewable( something, e.stageX, e.stageY );
				
				if ( dummyViewable == null )
				{
					continue;
				}
				
				//check if this object was already processed within current updating cycle (in case the same object will be faced twice as a result to getObjectsUnderPoint() call if have multiple overlapping childrens (dunno how that function works)):
				var processed:Boolean = false;
				for each ( var processedDummyViewable:DummyViewable in newOver )
				{
					if ( processedDummyViewable == dummyViewable )
					{
						processed = true;
						break;
					}
				}
				if ( processed )
				{
					continue;
				}
				
				newOver.push( dummyViewable );
				
				var alreadyOver:Boolean = false;
				for ( var i:int = 0; i < _currentOver.length; ++i )
				{
					if ( _currentOver[ i ] == dummyViewable )
					{
						_currentOver[ i ] = null;
						alreadyOver = true;
						break;
					}
				}
				if ( alreadyOver == false )
				{
					_mouseHandler( MOUSE_OVER, dummyViewable._opaqueData );
				}
				
				_mouseHandler( MOUSE_HOVER, dummyViewable._opaqueData );
			}
			
			//any left objects within _currentOver are not mentioned within current cycle, so they are hovered out:
			for each ( var previous:DummyViewable in _currentOver )
			{
				if ( previous == null )
				{
					continue;
				}
				
				_mouseHandler( MOUSE_OUT, previous._opaqueData );
			}
			
			_currentOver = newOver;
		}
		
		private function OnMouseDown( e:MouseEvent ): void
		{
			_mousePos.x = e.localX;
			_mousePos.y = e.localY;
			
			for each ( var something:* in _viewport.getObjectsUnderPoint( _mousePos ) )
			{
				var dummyViewable:DummyViewable = AsDummyViewable( something, e.stageX, e.stageY );
				
				if ( dummyViewable != null )
				{
					_mouseHandler( MOUSE_DOWN, dummyViewable._opaqueData );
					_mouseDown.push( dummyViewable );
				}
			}
		}
		
		private function OnMouseUp( e:MouseEvent ): void
		{
			for each ( var dummyViewable:DummyViewable in _mouseDown )
			{
				_mouseHandler( MOUSE_UP, dummyViewable._opaqueData );
			}
			_mouseDown.length = 0;
		}
	}

}


