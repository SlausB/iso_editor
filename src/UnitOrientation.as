///@cond
package
{
	
	///@endcond
	
	
	/** Information sufficient for unit's view creation.*/
	public class UnitOrientation
	{
		public var _startingFrame : int;
		public var _endingFrame : int;
		public var _orientation : int;
		
		
		public function UnitOrientation( startingFrame : int, endingFrame : int, orientation : int )
		{
			_startingFrame = startingFrame;
			_endingFrame = endingFrame;
			_orientation = orientation;
		}
		
	}

}

