///@cond
package
{
	import blisc.BliscAnimation;
	
	///@endcond
	
	/** Animation for specified orientation.*/
	public class UnitView 
	{
		public var _orientation:int;
		public var _animation:BliscAnimation;
		
		public function UnitView( orientation:int, animation:BliscAnimation )
		{
			_orientation = orientation;
			_animation = animation;
		}
		
	}

}

