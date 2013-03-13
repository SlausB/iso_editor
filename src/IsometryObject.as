///@cond
package  
{
	import blisc.BliscCompound;
	import blisc.BliscDisplayObject;
	import flash.filters.GlowFilter;
	import view.View;
	
	///@endcond
	
	/** Plays animation, shows selections. allow controlling and so on.*/
	public class IsometryObject 
	{
		public var _view:BliscCompound;
		
		private var _elapsed:Number = 0;
		
		
		public function IsometryObject( view:BliscCompound = null )
		{
			_view = view;
		}
		
		public function OnMouseEvent( type:int ): void
		{
			trace( "mouse event: " + type.toString() );
			
			switch ( type )
			{
				case View.MOUSE_OVER:
					bdo.Highlight( new GlowFilter( 0x00FF00, 1, 4, 4, 3 ) );
					break;
				
				case View.MOUSE_OUT:
					bdo.Unhighlight();
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
			_view = null;
		}
		
	}

}

