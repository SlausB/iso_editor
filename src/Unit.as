///@cond
package
{
	import blisc.BliscCompound;
	import blisc.unit_actions.MoveDirectly;
	import blisc.unit_actions.UnitAction;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import project_data.Map;
	import project_data.ObjectInstance;
	import utils.Utils;
	
	///@endcond
	
	
	/** Random walking unit within isometry.*/
	public class Unit extends IsometryObject
	{
		public var _unitDesc:UnitDesc;
		
		private var _currentAction:UnitAction = null;
		
		private var _isoDest:Point = new Point;
		
		
		public function Unit( main:Main, unitDesc:UnitDesc )
		{
			super( null, main );
			
			_unitDesc = unitDesc;
			
			MoveRandomly();
		}
		
		public function get unitDesc(): UnitDesc
		{
			return _unitDesc;
		}
		
		override public function Update( elapsedSeconds:Number ): void
		{
			if ( _currentAction == null )
			{
				return;
			}
			
			const left:Number = elapsedSeconds - _currentAction.Proceed( elapsedSeconds );
			//ended:
			if ( left > 0 )
			{
				if ( _currentAction is MoveDirectly )
				{
					MoveRandomly( _isoDest.x, _isoDest.y );
					_currentAction.Proceed( left );
				}
			}
		}
		
		private function get map(): Map
		{
			return _main._isometry.displaying;
		}
		
		private function MoveRandomly( startX:Number = 0, startY:Number = 0 ): void
		{
			if ( _currentAction != null )
			{
				_currentAction.Destroy();
			}
			
			Utils.ToIso( Utils.RandomInt( -map._right, map._right ), Utils.RandomInt( -map._down, map._down ), _isoDest );
			_currentAction = new MoveDirectly( this, map, startX, startY, _isoDest.x, _isoDest.y );
		}
		
		override public function Highlight( glowFilter:GlowFilter ): void
		{
			_view.bdo.Highlight( glowFilter );
		}
		
		override public function Unhighlight(): void
		{
			_view.bdo.Unhighlight();
		}
		
		public function MoveTo( isoX:Number, isoY:Number, tiled:Boolean = false ): void
		{
			if ( _currentAction != null )
			{
				_currentAction.Destroy();
			}
			
			_isoDest.setTo( isoX, isoY );
			
			if ( tiled )
			{
				//TODO...
			}
			else
			{
				_currentAction = new MoveDirectly( this, _main._isometry.displaying, _view.bdo.GetIsoX(), _view.bdo.GetIsoY(), isoX, isoY );
			}
		}
		
	}

}

