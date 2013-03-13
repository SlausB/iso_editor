///@cond
package project_data
{
	import flash.geom.Point;
	import project_data.ObjectTemplate;
	
	///@endcond
	
	/** Concrete object specified within some location.*/
	public class ObjectInstance 
	{
		public var _template:ObjectTemplate;
		
		/** Physical (not tile) isometric coordinates. Other coordinates (screen or tile) are resolved using it.*/
		public var _isoCoords:Point = new Point( 0, 0 );
		
		
		public function Init( template:ObjectTemplate ): void
		{
			_template = template;
		}
	}

}

