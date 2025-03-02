///@cond
package blisc.unit_actions
{
	import blisc.instances.BliscUnit;
	import blisc.templates.BliscUnitTemplate;
	import blisc.templates.BliscUnitView;
	import com.junkbyte.console.Cc;
	import flash.geom.Point;
	import iso.orient.Orientation;
	import utils.Utils;
	
	///@endcond
	
	
	/** Move unit strictly to specified point.*/
	public class MoveDirectly extends UnitAction
	{
		private var _speed : Number;
		
		private var _isoStartX : Number;
		private var _isoStartY : Number;
		
		private var _isoDestX : Number;
		private var _isoDestY : Number;
		
		/** How much moved along chosen path.*/
		private var _moved : Number = 0;
		/** Seconds animation was playing while moving in specified direction.*/
		public var _played : Number = 0;
		
		/** True if "_played" value is specified before each Proceed() call.*/
		private var _overridePlayed : Boolean = false;
		
		/** Cached values.*/
		private var _view : BliscUnitView;
		private var _dispX : Number;
		private var _dispY : Number;
		private var _distance : Number;
		
		
		public function MoveDirectly( unit : BliscUnit, template : BliscUnitTemplate, speed : Number, isoStartX : Number, isoStartY : Number, isoDestX : Number, isoDestY : Number, overridePlayed : Boolean = false )
		{
			super( unit, template );
			
			Init( unit, speed, isoStartX, isoStartY, isoDestX, isoDestY, overridePlayed );
		}
		
		public function Init( unit : BliscUnit, speed : Number, isoStartX : Number, isoStartY : Number, isoDestX : Number, isoDestY : Number, overridePlayed : Boolean ) : void
		{
			_unit = unit;
			
			_speed = speed;
			
			_isoStartX = isoStartX;
			_isoStartY = isoStartY;
			
			_isoDestX = isoDestX;
			_isoDestY = isoDestY;
			
			_overridePlayed = overridePlayed;
			
			
			_dispX = _isoDestX - _isoStartX;
			_dispY = _isoDestY - _isoStartY;
			
			_distance = Math.sqrt( _dispX * _dispX + _dispY * _dispY );
			
			var planarDisp : Point = Utils.FromIso( _dispX, _dispY, new Point );
			_view = _template.GetAnimation( Utils.PointToRadians( planarDisp.x, planarDisp.y ) );
			
			
			_moved = 0;
			_played = 0;
		}
		
		override public function Proceed( seconds : Number ) : Number
		{
			if ( _view == null || _view._animation == null )
			{
				Cc.error( "E: MoveDirectly.Proceed(): view is null." );
				return 0;
			}
			
			_moved += seconds * _speed;
			
			if ( _overridePlayed == false )
			{
				_played += seconds;
			}
			
			if ( _dispX != 0 || _dispY != 0 )
			{
				const traveled : Number = Math.min( _moved / _distance, 1.0 );
				
				_unit.SetIsoXY( _isoStartX + ( _dispX * traveled ), _isoStartY + ( _dispY * traveled ) );
				
				_unit.Replicate( _view._animation.Resolve( _played ) );
			}
			
			
			if ( _moved >= _distance )
			{
				const left : Number = ( _moved - _distance ) / _speed;
				_moved = 0;
				_played = 0;
				
				return ( seconds - left );
			}
			
			return seconds;
		}
		
		override public function get orientation() : int
		{
			if ( _view == null )
			{
				Cc.error( "E: MoveDirectly.get orientation(): view is null." );
				return Orientation.U;
			}
			return _view._orientation;
		}
		
	}

}

