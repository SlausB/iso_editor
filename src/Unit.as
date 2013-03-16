///@cond
package
{
	import blisc.BliscCompound;
	import flash.geom.Point;
	import project_data.ObjectInstance;
	
	///@endcond
	
	
	/** Random walking unit within isometry.*/
	public class Unit extends IsometryObject
	{
		private var _unitDesc:UnitDesc;
		
		private var _moved:Number = 0;
		private var _isoStart:Point = new Point;
		private var _isoDest:Point = new Point;
		
		private var _curIsoPos:Point = new Point;
		
		
		public function Unit( main:Main, unitDesc:UnitDesc )
		{
			super( null, main );
			
			_unitDesc = unitDesc;
		}
		
		override public function OnMouseEvent( type:int ): void
		{
		}
		
		override public function Over(): void
		{
		}
		override public function Out(): void
		{
		}
		override public function Select(): void
		{
		}
		override public function Deselect(): void
		{
		}
		
		override public function Update( elapsedSeconds:Number ): void
		{
			_moved += elapsedSeconds;
			
			_curIsoPos.x = _view.bdo.GetIsoX();
			_curIsoPos.y = _view.bdo.GetIsoY();
			
			_view.bdo.SetIsoX( _moved * _main._isometry.displaying._unitsSpeed );
			_view.bdo.Replicate( _unitDesc._views[ 0 ]._animation.Resolve( _moved ) );
		}
		
	}

}