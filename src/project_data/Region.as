///@cond
package project_data 
{
	
	///@endcond
	
	/** Object's occupying tile space type description.*/
	public class Region
	{
		public var _name:String = "Undefined";
		
		/** Dunno.*/
		public static const TYPE_UNDEFINED:int = 1;
		/** Who can NOT walk on specified tile.*/
		public static const TYPE_SURFACE:int = 2;
		/** Occupying space.*/
		public static const TYPE_SPACE:int = 3;
		
		/** One of TYPE_... .*/
		public var _type:int = TYPE_SURFACE;
		
		/** How to draw and identificate this region.*/
		public var _color:uint = 0x00000000;
	}

}

