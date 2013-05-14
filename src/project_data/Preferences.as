///@cond
package project_data
{
	
	///@endcond
	
	
	public class Preferences
	{
		public static const MOVING_WAY_SENSORA : int = 1;
		public static const MOVING_WAY_PULLINY : int = 2;
		
		/** How objects within isometry must be moved using mouse when `moving` property is set.*/
		public var _movingWay : int = MOVING_WAY_PULLINY;
		
		/** When `pulliny` moving way is active and this toggled on object will keep spawning after it's first instance.*/
		public var _spawning : Boolean = false;
	}

}

