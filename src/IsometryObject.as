///@cond
package  
{
	import blisc.BliscComplexWithinCompound;
	import blisc.BliscCompound;
	import blisc.BliscDisplayObject;
	import blisc.BliscIsometric;
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
		public var _view:BliscIsometric;
		
		private var _elapsed:Number = 0;
		
		private var _selected:Boolean = false;
		private var _over:Boolean = false;
		
		
		public function IsometryObject( objectInstance:ObjectInstance, main:Main, view:BliscIsometric = null )
		{
			_objectInstance = objectInstance;
			_main = main;
			_view = view;
		}
		
		public function Select(): void
		{
			if ( _selected )
			{
				return;
			}
			
			_selected = true;
			
			_main._isometry._selected = this;
			_main.ShowObjectProperties();
			
			ShowSelectHighlight();
		}
		
		public function Deselect(): void
		{
			if ( _selected == false )
			{
				return;
			}
			
			_selected = false;
			_main._isometry._selected = null;
			_main.ShowObjectProperties();
			
			Unhighlight();
			
			if ( _over )
			{
				ShowOverHighlight();
			}
		}
		
		public function Over(): void
		{
			if ( _over )
			{
				return;
			}
			
			_over = true;
			
			if ( _selected == false )
			{
				_main._isometry.HideTip();
				_main._isometry._objectTip = ToolTipManager.createToolTip( _objectInstance._template._name, _main.stage.mouseX, _main.stage.mouseY );
				
				ShowOverHighlight();
			}
		}
		
		private function ShowOverHighlight(): void
		{
			Highlight( new GlowFilter( 0x00FF00, 1, 8, 8, 3 ) );
		}
		
		private function ShowSelectHighlight(): void
		{
			Highlight( new GlowFilter( 0xFF6100, 1, 10, 10 ) );
		}
		
		public function Out(): void
		{
			if ( _over == false )
			{
				return;
			}
			
			_over = false;
			
			Unhighlight();
			_main._isometry.HideTip();
			
			if ( _selected )
			{
				ShowSelectHighlight();
			}
		}
		
		public function OnMouseEvent( type:int ): void
		{
			trace( "mouse event: " + type.toString() );
			
			switch ( type )
			{
				case View.MOUSE_OVER:
					if ( _main._isometry._over != this )
					{
						if ( _main._isometry._over != null )
						{
							_main._isometry._over.Out();
						}
						
						Over();
						_main._isometry._over = this;
					}
					break;
				
				case View.MOUSE_OUT:
					Out();
					_main._isometry._over = null;
					break;
				
				case View.MOUSE_CLICK:
					if ( _main._isometry._selected == this )
					{
						Deselect();
					}
					else
					{
						if ( _main._isometry._selected != null )
						{
							_main._isometry._selected.Deselect();
						}
						
						Select();
						_main._isometry._selected = this;
					}
					break;
			}
		}
		
		private function get bdo(): BliscDisplayObject
		{
			return _view.bdo;
		}
		
		public function Update( elapsedSeconds:Number ): void
		{
			_elapsed += elapsedSeconds;
			
			var compound:BliscCompound = _view as BliscCompound;
			
			for each ( var complexWithinCompound:BliscComplexWithinCompound in compound._complexes )
			{
				complexWithinCompound._complex._bdo.Replicate( complexWithinCompound._template._complex._view.Resolve( _elapsed ) );
			}
		}
		
		public function Highlight( glowFilter:GlowFilter ): void
		{
			var compound:BliscCompound = _view as BliscCompound;
			
			for each ( var complexWithinCompound:BliscComplexWithinCompound in compound._complexes )
			{
				complexWithinCompound._complex._bdo.Highlight( glowFilter );
			}
		}
		
		public function Unhighlight(): void
		{
			var compound:BliscCompound = _view as BliscCompound;
			
			for each ( var complexWithinCompound:BliscComplexWithinCompound in compound._complexes )
			{
				complexWithinCompound._complex._bdo.Unhighlight();
			}
		}
		
		public function Destroy(): void
		{
			_main = null;
			_view.Destroy();
			_view = null;
		}
		
	}

}

