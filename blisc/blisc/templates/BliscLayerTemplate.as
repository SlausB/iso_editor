///@cond
package blisc.templates
{
	
	///@endcond
	
	
	public class BliscLayerTemplate
	{
		public var _name : String;
		
		/** Is default layer for units.*/
		public var _units : Boolean;
		
		/** Set to false if you do not wanna objects within this layer to be selected and to hide overlapping objects while hovering mouse over it.*/
		public var _selectable : Boolean;
		
		
		public function BliscLayerTemplate( name : String, units : Boolean, selectable : Boolean )
		{
			_name = name;
			_units = units;
			_selectable = selectable;
		}
		
	}

}

