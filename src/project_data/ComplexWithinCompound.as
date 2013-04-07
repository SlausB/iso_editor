///@cond
package project_data
{
	
	///@endcond
	
	/** Complex instance within compound object specification.*/
	public class ComplexWithinCompound
	{
		public var _complex : ComplexTemplate;
		
		/** Tile (not physical) isometric displacement relative to compound coordinates.*/
		public var _tileDispX : Number;
		public var _tileDispY : Number;
		
		
		public function Init( complex : ComplexTemplate, tileDispX : Number, tileDispY : Number ) : void
		{
			_complex = complex;
			
			_tileDispX = tileDispX;
			_tileDispY = tileDispY;
		}
		
		public function Destroy() : void
		{
			_complex = null;
		}
	}

}

