///@cond
package project_data
{
	import flash.geom.Point;
	import project_data.ObjectTemplate;
	
	///@endcond
	
	/** Concrete object specified within some location.*/
	public class ObjectInstance
	{
		public var _template : ObjectTemplate;
		
		/** Tile (not physical) isometric coordinates. Other coordinates (screen or physical) are resolved using it.*/
		public var _tileCoords : Point = new Point;
		
		
		public function Init( template : ObjectTemplate ) : void
		{
			_template = template;
		}
	}

}



