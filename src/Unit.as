///@cond
package
{
	import blisc.BliscCompound;
	import flash.geom.Point;
	import project_data.Map;
	import project_data.ObjectInstance;
	import utils.Utils;
	
	///@endcond
	
	
	/** Random walking unit within isometry.*/
	public class Unit extends IsometryObject
	{
		private var _unitDesc:UnitDesc;
		
		/** How much moved along chosen path.*/
		private var _moved:Number = 0;
		/** Seconds animation was playing while moving in specified direction.*/
		private var _played:Number = 0;
		/** Start of the path.*/
		private var _isoStart:Point = new Point;
		/** End of the path.*/
		private var _isoDest:Point = new Point;
		
		/** Just caching.*/
		private var _curIsoPos:Point = new Point;
		private var _planarDisp:Point = new Point;
		
		
		public function Unit( main:Main, unitDesc:UnitDesc )
		{
			super( null, main );
			
			_unitDesc = unitDesc;
		}
		
		public function get unitDesc(): UnitDesc
		{
			return _unitDesc;
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
			var map:Map = _main._isometry.displaying;
			
			_moved += elapsedSeconds * map._unitsSpeed;
			_played += elapsedSeconds;
			
			_curIsoPos.x = _view.bdo.GetIsoX();
			_curIsoPos.y = _view.bdo.GetIsoY();
			
			const dispX:Number = _isoDest.x - _isoStart.x;
			const dispY:Number = _isoDest.y - _isoStart.y;
			
			const distance:Number = Math.sqrt( dispX * dispX + dispY * dispY );
			
			if ( dispX != 0 && dispY != 0 )
			{
				const traveled:Number = Math.min( _moved / distance, 1.0 );
				
				_view.bdo.SetIsoX( _isoStart.x + ( dispX * traveled ) );
				_view.bdo.SetIsoY( _isoStart.y + ( dispY * traveled ) );
				
				Utils.FromIso( dispX, dispY, _planarDisp );
				const radians:Number = Utils.PointToRadians( _planarDisp.x, _planarDisp.y );
				_view.bdo.Replicate( _unitDesc.GetAnimation( radians ).Resolve( _played ) );
			}
			
			
			if ( _moved >= distance )
			{
				_isoStart.copyFrom( _isoDest );
				Utils.ToIso( Utils.RandomInt( -map._right, map._right ), Utils.RandomInt( -map._down, map._down ), _isoDest );
				
				const left:Number = ( _moved - distance ) / map._unitsSpeed;
				_moved = 0;
				_played = 0;
				
				Update( left );
			}
		}
		
	}

}