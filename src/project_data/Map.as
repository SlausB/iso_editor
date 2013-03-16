///@cond
package project_data
{
	
	///@endcond
	
	/** Predefined isometric location consisting of template objects.
	Possible future extentions: events (quests, dialogs...), interconnections (paths from one location to another...) ... */
	public class Map
	{
		public var _name:String = "Undefined";
		
		/** Objects within this map.*/
		public var _instances:Vector.< ObjectInstance > = new Vector.< ObjectInstance >;
		
		/** How far map is stretched to both right and left around it's center.*/
		public var _right:Number = 1000;
		/** How far map is stretched to both up and down around it's center.*/
		public var _down:Number = 1000;
		
		/** Is it need to display map-sized frame within map editing window.*/
		public var _drawBorder:Boolean = true;
		/** Is it need to display tiled grid within map editing window.*/
		public var _drawGrid:Boolean = true;
		/** Is it need to floor dragging object's coordinates to tile.*/
		public var _clampToTiles:Boolean = false;
	}

}

