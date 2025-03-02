///@cond
package blisc.templates
{
	import blisc.core.BliscAnimation;
	
	///@endcond
	
	
	public class BliscUnitTemplate
	{
		/** Name without any "unit_" prefix or "_idle/_move" postfix.*/
		public var _name : String;
		
		/** Animation type name. I.e. something like "idle", "move"... .*/
		public var _animation : String;
		
		/** Surfaces this unit is walking on.*/
		public var _surfaces : Vector.< BliscRegion >;
		
		/** All recognized orientations.*/
		public var _views : Vector.< BliscUnitView >;
		
		/** Which directions unit cannot go.*/
		public var _refusedDirections : Vector.< int > = new Vector.< int >;
		
		
		public function BliscUnitTemplate(
			name : String,
			animation : String,
			surfaces : Vector.< BliscRegion >,
			views : Vector.< BliscUnitView >,
			refusedDirections : Vector.< int >
		)
		{
			_name = name;
			_animation = animation;
			_surfaces = surfaces;
			_views = views;
			_refusedDirections = refusedDirections;
		}
		
		/** North is zero.*/
		public function GetAnimation( radians : Number ) : BliscUnitView
		{
			if ( radians < 0 )
			{
				radians = Math.PI * 2.0 + radians;
			}
			
			//clamp hesitating angles to it's definite direction to avoid animation orientation flipping:
			const EPSILON : Number = Math.PI / 360.0;
			//north:
			if ( radians < EPSILON || radians > ( Math.PI * 2.0 - EPSILON ) )
			{
				radians = 0;
			}
			//east:
			else if ( radians > ( Math.PI / 2.0 - EPSILON ) && radians < ( Math.PI / 2.0 + EPSILON ) )
			{
				radians = Math.PI / 2.0;
			}
			//south:
			else if ( radians > ( Math.PI - EPSILON ) && radians < ( Math.PI + EPSILON ) )
			{
				radians = Math.PI;
			}
			//west:
			else if ( radians > ( Math.PI * 1.5 - EPSILON ) && radians < ( Math.PI * 1.5 + EPSILON ) )
			{
				radians = Math.PI * 1.5;
			}
			
			var closest : BliscUnitView = null;
			var closestDistance : Number = Number.MAX_VALUE;
			for each ( var unitView : BliscUnitView in _views )
			{
				const distance : Number = Math.abs( unitView._radians - radians );
				
				if ( closest == null )
				{
					closest = unitView;
					closestDistance = distance;
					continue;
				}
				
				if ( distance < closestDistance )
				{
					closest = unitView;
					closestDistance = distance;
				}
				else if ( distance == closestDistance )
				{
					//we stated that clockwise orientation must be chosen (if unit goes north but there are no "N" orientation, then "NE" must be chosen instead of "NW"):
					if ( unitView._radians > radians )
					{
						closest = unitView;
						closestDistance = distance;
					}
				}
			}
			
			return closest;
		}
		
		/** Makes original resource name as it was specified within graphics.*/
		public function MakeFullName() : String
		{
			return "unit_" + _animation + "_" + _name;
		}
	}

}

