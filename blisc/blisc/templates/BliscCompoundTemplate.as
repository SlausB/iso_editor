///@cond
package blisc.templates 
{
	
	///@endcond
	
	/** Consisting of multiple objects, each of which can be within it's own layer with it's own displacement (graphical and occupying).*/
	public class BliscCompoundTemplate extends BliscObjectTemplate
	{
		public var _complexes : Vector.< BliscComplexWithinCompoundTemplate >;
		
		
		public function BliscCompoundTemplate( name : String, complexes : Vector.< BliscComplexWithinCompoundTemplate > )
		{
			super( name );
			
			_complexes = complexes;
		}
	}

}

