///@cond
package blisc.instances 
{
	import blisc.core.BliscDisplayObject;
	import blisc.templates.BliscObjectTemplate;
	import flash.geom.Point;
	
	///@endcond
	
	/** Some graphical object allocated within map.*/
	public class BliscMapObject 
	{
		/** Can be both ordinary or compound object.*/
		public var _object : BliscObjectTemplate;
		
		/** Physical (not tile) isometric coordinates.*/
		public var _isoCoords : Point;
		
		
		public function BliscMapObject( object : BliscDisplayObject, isoCoords : Point )
		{
			_object = object;
			_isoCoords = isoCoords;
		}
		
	}

}

