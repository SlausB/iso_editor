///@cond
package project_data
{
	///@endcond
	
	/** Display layer within some map.*/
	public class Layer 
	{
		public var _name : String = "Undefined";
		
		/** Is default layer for units.*/
		public var _units : Boolean = false;
		
		/** True if map's gris must be displayed on the bottom of this layer.*/
		public var _gridHolder : Boolean = false;
		
		/** Are objects within this layer should be displayed.*/
		public var _visible : Boolean = true;
		
		/** Set to false if you do not wanna objects within this layer to be selected and to hide overlapping objects while hovering mouse over it.*/
		public var _selectable : Boolean = true;
	}

}

