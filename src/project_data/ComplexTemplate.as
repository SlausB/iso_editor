///@cond
package project_data
{
	import flash.geom.Point;
	import project_data.Layer;
	import project_data.ObjectTemplate;
	
	///@endcond
	
	/** Static isometric object definition.*/
	public class ComplexTemplate extends ObjectTemplate
	{
		/** Graphical representation.*/
		public var _singleResource:SingleResource = null;
		/** Planar displacement coordinates for it's graphical representation.*/
		public var _dispX:Number = 0;
		public var _dispY:Number = 0;
		
		/** Relative coordinates of occupying tiles.*/
		public var _tiles:Vector.< Point > = new Vector.< Point >;
		
		/** Within which layers this object must be displayed. Null if wasn't specified yet.*/
		public var _layer:Layer = null;
		
		/** Physical object's center to properly sort this object while drawing.*/
		public var _centerX:Number = 0;
		public var _centerY:Number = 0;
	}

}

