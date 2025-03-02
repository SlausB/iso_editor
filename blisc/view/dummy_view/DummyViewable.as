///@cond
package view.dummy_view 
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import view.Projection;
	import view.View;
	import view.Viewable;
	
	///@endcond
	
	public class DummyViewable extends Sprite implements Viewable
	{
		public var _howItLooks:Bitmap;
		public var _opaqueData:*;
		public var _projection:Projection;
		public var _view:View;
		
		
		public function DummyViewable( howItLooks:Bitmap, opaqueData:*, projection:Projection, view:View )
		{
			_howItLooks = howItLooks;
			_opaqueData = opaqueData;
			_projection = projection;
			
			addChild( _howItLooks );
		}
		
		public function SetX( x:Number ): void
		{
			_howItLooks.x = _projection.X_FromSpaceToView( x );
		}
		
		public function SetY( y:Number ): void
		{
			_howItLooks.y = _projection.Y_FromSpaceToView( y );
		}
		
		public function SetZ( z:Number ): void
		{
		}
		
		public function GetX(): Number
		{
			return _projection.X_FromViewToSpace( _howItLooks.x );
		}
		
		public function GetY(): Number
		{
			return _projection.Y_FromViewToSpace( _howItLooks.y );
		}
		
		public function GetZ(): Number
		{
			return 0;
		}
		
		public function Destroy(): void
		{
			_view.Remove( this );
		}
		
	}

}



