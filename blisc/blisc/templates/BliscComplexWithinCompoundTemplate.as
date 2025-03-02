///@cond
package blisc.templates 
{
	import flash.geom.Point;
	import utils.Utils;
	
	///@endcond
	
	public class BliscComplexWithinCompoundTemplate
	{
		public var _complex : BliscComplexTemplate;
		/** Tile (not physical) isometric displacement accordingly whole Compound position.*/
		public var _tileDisp : Point;
		
		
		public function BliscComplexWithinCompoundTemplate( complex : BliscComplexTemplate, tileDisp : Point )
		{
			_complex = complex;
			_tileDisp = tileDisp;
		}
		
	}

}

