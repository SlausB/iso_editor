///@cond
package blisc.templates
{
	import flash.geom.Point;
	
	///@endcond
	
	
	/** BliscObjectTemplate instance within some map at specified place.*/
	public class BliscObjectInstanceTemplate
	{
		public var _template : BliscObjectTemplate;
		
		/** Tile isometric (not planar) object's position.*/
		public var _tilePos : Point;
		
		
		public function BliscObjectInstanceTemplate( template : BliscObjectTemplate, tilePos : Point )
		{
			_template = template;
			_tilePos = tilePos;
		}
		
	}

}

