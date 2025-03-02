///@cond
package blisc.templates 
{
	///@endcond
	
	
	/** Isometric object's surface (walkability type) or space (dimensions) specification.*/
	public class BliscRegion
	{
		/** Can be used for referencing.*/
		public var _name : String;
		
		
		public static const TYPE_UNDEFINED : int = 1;
		public static const TYPE_SURFACE : int = 2;
		public static const TYPE_SPACE : int = 3;
		
		public var _type : int;
		
		public var _color : uint;
		
		
		public function BliscRegion( name : String, type : int, color : uint )
		{
			_name = name;
			_type = type;
			_color = color;
		}
		
	}

}

