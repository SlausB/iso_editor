///@cond
package  
{
	import blisc.BliscCompound;
	import blisc.BliscDisplayObject;
	import flash.filters.GlowFilter;
	import ie.Isometry;
	import mx.managers.ToolTipManager;
	import project_data.ObjectInstance;
	import view.View;
	
	///@endcond
	
	/** Plays animation, shows selections. allow controlling and so on.*/
	public class IsometryObject 
	{
		public var _objectInstance:ObjectInstance;
		public var _main:Main;
		public var _view:BliscCompound;
		
		private var _elapsed:Number = 0;
		
		
		public function IsometryObject( objectInstance:ObjectInstance, main:Main, view:BliscCompound = null )
		{
			_objectInstance = objectInstance;
			_main = main;
			_view = view;
		}
		
		public function OnMouseEvent( type:int ): void
		{
			trace( "mouse event: " + type.toString() );
			
			switch ( type )
			{
				case View.MOUSE_OVER:
					if ( _main._isometry._selected != this )
					{
						_main._isometry.HideTip();
						_main._isometry._objectTip = ToolTipManager.createToolTip( _objectInstance._template._name, _main.stage.mouseX, _main.stage.mouseY );
						bdo.Highlight( new GlowFilter( 0x00FF00, 1, 8, 8, 3 ) );
					}
					break;
				
				case View.MOUSE_OUT:
					if ( _main._isometry._selected != this )
					{
						_main._isometry.HideTip();
						bdo.Unhighlight();
					}
					break;
				
				case View.MOUSE_CLICK:
					if ( _main._isometry._selected != this )
					{
						if ( _main._isometry._selected != null )
						{
							_main._isometry._selected.bdo.Unhighlight();
						}
						_main._isometry._selected = this;
						bdo.Highlight( new GlowFilter( 0xFF6100, 1, 10, 10 ) );
						
						_main.SetObjectTilePos( _objectInstance._tileCoords.x, _objectInstance._tileCoords.y );
						
						_main._isometry.HideTip();
					}
					else
					{
						_main._isometry._selected = null;
						_main.ShowObjectProperties();
						bdo.Unhighlight();
					}
					break;
			}
		}
		
		private function get bdo(): BliscDisplayObject
		{
			return _view.At( 0 )._complex._bdo;
		}
		
		public function Update( elapsedSeconds:Number ): void
		{
			_elapsed += elapsedSeconds;
			
			bdo.Replicate( _view.At( 0 )._template._complex._view.Resolve( _elapsed ) );
		}
		
		public function Destroy(): void
		{
			_main = null;
			_view = null;
		}
		
	}

}

