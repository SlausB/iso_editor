///@cond
package blisc.templates 
{
	
	///@endcond
	
	/** Map description.*/
	public class BliscMapTemplate 
	{
		public var _name : String;
		
		/** How far the map goes to right from it's center. "Left" value is the same.*/
		public var _right : Number;
		
		/** How far the map goes to down from it's center. "Up value is the same.*/
		public var _down : Number;
		
		public var _objects : Vector.< BliscObjectInstanceTemplate >;
		
		
		public function BliscMapTemplate( name : String, right : Number, down : Number, objects : Vector.< BliscObjectInstanceTemplate > )
		{
			_name = name;
			_right = right;
			_down = down;
			_objects = objects;
		}
	}

}

