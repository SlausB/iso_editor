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
		public var _disp:Point = new Point;
		
		/** Regions specified for this template - not necessarely all existing regions. Order is irrelevant.*/
		public var _regions:Vector.< RegionWithinComplex > = new Vector.< RegionWithinComplex >;
		
		/** Within which layers this object must be displayed. Null if wasn't specified yet.*/
		public var _layer:Layer = null;
		
		/** Physical object's center to properly sort this object while drawing (planar coordinates).*/
		public var _center:Point = new Point;
		
		/** Archaic field to avoid project loading errors/warnings - not used anymore.*/
		public var _tiles:Vector.< Point >;
	}

}

