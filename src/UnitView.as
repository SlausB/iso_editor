///@cond
package
{
	import blisc.BliscAnimation;
	import iso.orient.Orientation;
	import utils.Utils;
	
	///@endcond
	
	/** Animation for specified orientation.*/
	public class UnitView 
	{
		public var _orientation:int;
		/** Calculated orientation's angle.*/
		public var _radians:Number;
		public var _animation:BliscAnimation;
		
		
		public function UnitView( orientation:int, animation:BliscAnimation )
		{
			_orientation = orientation;
			_radians = Utils.DegreesToRadians( Orientation.ToDegrees( orientation ) );
			_animation = animation;
		}
		
	}

}

