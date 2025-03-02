///@cond

package blisc.templates 
{
	
	///@endcond
	
	/** Whole isometry specification.*/
	public class BliscTemplate
	{
		/** Distance from north to east.*/
		public var _tileSize:Number;
		
		public var _maps:Vector.< BliscMapTemplate > = new Vector.< BliscMapTemplate >;
		
		/** In order of appearance.*/
		public var _layers:Vector.< String > = new Vector.< String >;
		
		public var _complexes:Vector.< BliscComplexTemplate > = new Vector.< BliscComplexTemplate >;
		
		public var _compounds:Vector.< BliscCompoundTemplate > = new Vector.< BliscCompoundTemplate >;
		
		
		public function BliscTemplate( tileSize:Number )
		{
			_tileSize = tileSize;
		}
		
	}

}