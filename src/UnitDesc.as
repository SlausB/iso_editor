///@cond
package  
{
	import blisc.BliscAnimation;
	import iso.orient.Orientation;
	import project_data.SingleResource;
	import utils.Utils;
	
	///@endcond
	
	/** Formed description of identified unit.*/
	public class UnitDesc 
	{
		public var _name:String;
		
		/** Just do represent it somehow while dragging from list view to isometry.*/
		public var _singleResource:SingleResource;
		
		public var _views:Vector.< UnitView > = new Vector.< UnitView >;
		
		
		public function UnitDesc( name:String, singleResource:SingleResource )
		{
			_name = name;
			_singleResource = singleResource;
		}
		
		/** North is zero.*/
		public function GetAnimation( radians:Number ): BliscAnimation
		{
			if ( radians < 0 )
			{
				radians = Math.PI + radians;
			}
			
			var closest:UnitView = null;
			var closestDistance:Number = Number.MAX_VALUE;
			for each ( var unitView:UnitView in _views )
			{
				if ( closest == null )
				{
					closest = unitView;
					continue;
				}
				
				const distance:Number = Math.abs( unitView._radians - radians );
				if ( distance < closestDistance )
				{
					closest = unitView;
					closestDistance = distance;
				}
				else if ( distance == closestDistance )
				{
					//we stated that clockwise orientation must be chosen (if unit goes north but there are no "N" orientation, then "NE" must be chosen instead of "NW"):
					if ( distance <= Math.PI )
					{
						if ( unitView._radians > radians )
						{
							closest = unitView;
							closestDistance = distance;
						}
						//otherwise just let already the chosen to be the one...
					}
				}
			}
			
			return closest._animation;
		}
	}

}

