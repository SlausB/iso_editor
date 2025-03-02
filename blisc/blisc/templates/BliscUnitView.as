///@cond
package blisc.templates 
{
	import blisc.core.BliscAnimation;
	import iso.orient.Orientation;
	import utils.Utils;
	
	///@endcond
	
	
	/** Animation for specified orientation.*/
	public class BliscUnitView
	{
		public var _orientation : int;
		
		/** Calculated orientation's angle.*/
		public var _radians : Number;
		
		/** To load BliscAnimation from animations cache if needed.*/
		public var _animationId : int;
		/** Null if animation unloaded.*/
		public var _animation : BliscAnimation;
		
		
		public function BliscUnitView( orientation : int, animationId : int = -1, animation : BliscAnimation = null )
		{
			_orientation = orientation;
			
			_radians = Utils.DegreesToRadians( Orientation.ToDegrees( orientation ) );
			
			_animationId = animationId;
			_animation = animation;
		}
		
	}

}

