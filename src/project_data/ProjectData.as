///@cond
package project_data
{
	
	///@endcond
	
	/** Used to write into some file and read out of it.*/
	public class ProjectData 
	{
		/** Distance from tile's center to east.*/
		public var _tileSize:Number = 40;
		
		public var _resources:Vector.< Resource > = new Vector.< Resource >;
		
		public var _objects:Vector.< ObjectTemplate > = new Vector.< ObjectTemplate >;
		
		public var _maps:Vector.< Map > = new Vector.< Map >;
		
		/** In order of appearance (from lower to upper).*/
		public var _layers:Vector.< Layer > = new Vector.< Layer >;
		
		/** Where project generates AS3 files for future usage within game itself. Null if path wasn't specified yet.*/
		public var _generationFolder:String = null;
		
		public var _regions:Vector.< Region > = new Vector.< Region >;
		
		/** Not exactly for any existing unit - only that was specified.*/
		public var _unitProperties:Vector.< UnitProperties > = new Vector.< UnitProperties >;
	}

}