///@cond
package blisc.unit_actions
{
	import blisc.core.BliscAnimation;
	import blisc.instances.BliscUnit;
	import blisc.templates.BliscUnitTemplate;
	import blisc.templates.BliscUnitView;
	import com.junkbyte.console.Cc;
	import iso.orient.Orientation;
	import utils.Utils;
	
	///@endcond
	
	
	public class Idle extends UnitAction
	{
		private var _seconds : Number;
		
		private var _played : Number = 0;
		
		private var _view : BliscUnitView;
		
		
		/** .
		\param template Animation to use as idle.
		\param orientation Which orientation to stay.
		\param seconds How long animation must be player or 0 if need to play single cycle.
		\param played Starting animation displacement. Can be used to get rid of multiple animations playing the same rythm. 1 - single cycle.
		\param radians If >= 0 than used to resolve animation's orientation insteand of "orientation" parameter.
		*/
		public function Idle( unit : BliscUnit, template : BliscUnitTemplate, orientation : int = Orientation.S, seconds : Number = 0, played : Number = 0, radians : Number = -1 )
		{
			super( unit, template );
			
			_seconds = seconds;
			
			if ( template == null )
			{
				Cc.error( "E: Idle.Idle(): template is null." );
				return;
			}
			
			var passingRadians : Number = radians >= 0 ? radians : Utils.DegreesToRadians( Orientation.ToDegrees( orientation ) );
			_view = template.GetAnimation( passingRadians );
			if ( _view == null )
			{
				Cc.error( "E: Idle.Idle(): view wasn't resolved." );
				return;
			}
			
			if ( played > 0 )
			{
				_played = _view._animation._period * played;
			}
		}
		
		override public function Proceed( seconds : Number ) : Number
		{
			if ( _template == null || _view == null || _view._animation == null )
			{
				return seconds;
			}
			
			_played += seconds;
			_unit.bdo.Replicate( _view._animation.Resolve( _played ) );
			
			if ( _seconds <= 0 )
			{
				if ( _played >= _view._animation.period )
				{
					return ( seconds - ( _played - _view._animation.period ) );
				}
			}
			else
			{
				if ( _played > _seconds )
				{
					return ( seconds - ( _played - _seconds ) );
				}
			}
			
			return seconds;
		}
		
		override public function get orientation() : int
		{
			if ( _view == null )
			{
				Cc.error( "E: Idle.get orientation(): view is null." );
				return Orientation.U;
			}
			return _view._orientation;
		}
		
	}

}

