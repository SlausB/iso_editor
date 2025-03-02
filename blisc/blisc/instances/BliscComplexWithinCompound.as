///@cond
package blisc.instances 
{
	import blisc.templates.BliscComplexWithinCompoundTemplate;
	import flash.geom.Point;
	
	///@endcond
	
	
	public class BliscComplexWithinCompound 
	{
		public var _template : BliscComplexWithinCompoundTemplate;
		public var _complex : BliscComplex;
		
		/** Cache of _tileDisp field within _template.*/
		public var _flatDisp : Point;
		
		
		public function BliscComplexWithinCompound( template : BliscComplexWithinCompoundTemplate, complex : BliscComplex, flatDisp : Point )
		{
			_template = template;
			_complex = complex;
			_flatDisp = flatDisp;
		}
		
		public function Destroy(): void
		{
			_template = null;
			
			if ( _complex != null )
			{
				_complex.Destroy();
				_complex = null;
			}
		}
		
	}

}

