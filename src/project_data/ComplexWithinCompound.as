///@cond
package project_data
{
	
	///@endcond
	
	/** Complex instance within compound object specification.*/
	public class ComplexWithinCompound
	{
		public var _complex:ComplexTemplate;
		
		/** Physical (not tile) isometric displacement relative to compound coordinates.*/
		public var _isoDispX:Number;
		public var _isoDispY:Number;
		
		
		public function Init( complex:ComplexTemplate, isoDispX:Number, isoDispY:Number ): void
		{
			_complex = complex;
			
			_isoDispX = isoDispX;
			_isoDispY = isoDispY;
		}
		
		public function Destroy(): void
		{
			_complex = null;
		}
	}

}

