///@cond
package blisc.templates 
{
	import blisc.core.BliscAnimation;
	import flash.geom.Point;
	
	///@endcond
	
	/** Which tiles occupies, which animation displays it.*/
	public class BliscComplexTemplate extends BliscObjectTemplate
	{
		/** To load BliscAnimation from animations cache if needed.*/
		public var _animationId : int;
		/** Single pointer can be referenced from multiple instances. Null if animation is unloaded.*/
		public var _view : BliscAnimation;
		/** Relative planar coordinates of Sprite's graphics around object's position.*/
		public var _disp : Point;
		/** Geometrical center to draw this object in a proper order (planar coordinates).*/
		public var _center : Point;
		/** Each complex of compound can be within it's own layer.*/
		public var _layer : String;
		/** All specified regions for this object. Order is irrelevant.*/
		public var _regions : Vector.< BliscRegionWithinComplex >;
		/** Should object react on mouse movements and clicks or not.*/
		public var _interactive : Boolean;
		
		
		public function BliscComplexTemplate(
			name : String,
			animationId : int,
			view : BliscAnimation,
			disp : Point,
			center : Point,
			layer : String,
			regions : Vector.< BliscRegionWithinComplex >,
			interactive : Boolean
		)
		{
			super( name );
			
			_view = view;
			_animationId = animationId;
			_disp = disp;
			_center = center;
			_layer = layer;
			_regions = regions;
			_interactive = interactive;
		}
		
	}

}



