///@cond
package project_data
{
	import flash.geom.Point;
	import project_data.ObjectTemplate;
	
	///@endcond
	
	/** Static isometric object definition.*/
	public class ComplexTemplate extends ObjectTemplate
	{
		/** Graphical representation.*/
		public var _singleResource : SingleResource = null;
		/** Planar displacement coordinates for it's graphical representation.*/
		public var _disp : Point = new Point;
		
		/** Regions specified for this template - not necessarely all existing regions. Order is irrelevant.*/
		public var _regions : Vector.< RegionWithinComplex > = new Vector.< RegionWithinComplex >;
		
		/** Within which layers this object must be displayed. Null if wasn't specified yet.*/
		public var _layer : Layer = null;
		
		/** Physical object's center to properly sort this object while drawing (planar coordinates).*/
		public var _center : Point = new Point;
		
		/** Archaic field to avoid project loading errors/warnings - not used anymore.*/
		public var _tiles : Vector.< Point >;
		
		/** Should object react on mouse movements and clicks or not.*/
		public var _interactive : Boolean = true;
		
		
		public function clone() : ComplexTemplate
		{
			var result : ComplexTemplate = new ComplexTemplate;
			
			result._name = _name;
			
			if ( _singleResource != null )
			{
				var sr : SingleResource = new SingleResource;
				sr.Init( _singleResource._resourcePath, _singleResource._name );
				result._singleResource = sr;
			}
			
			result._disp.x = _disp.x;
			result._disp.y = _disp.y;
			
			for ( var regionIndex : int = 0; regionIndex < _regions.length; ++regionIndex )
			{
				var copyingRWC : RegionWithinComplex = _regions[ regionIndex ];
				
				var rwc : RegionWithinComplex = new RegionWithinComplex;
				rwc.Init( copyingRWC._region );
				
				for ( var copyingRegionPointIndex : int = 0; copyingRegionPointIndex < copyingRWC._tiles.length; ++copyingRegionPointIndex )
				{
					var copyingRegionPoint : Point = copyingRWC._tiles[ copyingRegionPointIndex ];
					
					rwc._tiles.push( new Point( copyingRegionPoint.x, copyingRegionPoint.y ) );
				}
				
				result._regions.push( rwc );
			}
			
			result._layer = _layer;
			
			if ( _center != null )
			{
				result._center = new Point( _center.x, _center.y );
			}
			
			result._interactive = _interactive;
			
			return result;
		}
	}

}

