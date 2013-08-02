///@cond
package project_data
{
	
	///@endcond
	
	/** Consisting of multiple complexes.*/
	public class CompoundTemplate extends ObjectTemplate
	{
		public var _consisting : Vector.< ComplexWithinCompound > = new Vector.< ComplexWithinCompound >;
		
		
		public function clone() : CompoundTemplate
		{
			var result : CompoundTemplate = new CompoundTemplate;
			
			result._name = _name;
			
			for ( var i : int = 0; i < _consisting.length; ++i )
			{
				var copying : ComplexWithinCompound = _consisting[ i ];
				
				var cwc : ComplexWithinCompound = new ComplexWithinCompound;
				cwc.Init( copying._complex, copying._tileDispX, copying._tileDispY );
				
				result._consisting.push( cwc );
			}
			
			return result;
		}
	}
	
}

