///@cond
package utils
{
	import com.junkbyte.console.Cc;
	
	
	///@endcond
	
	
	/** Chooses between cases specified using "weight".*/
	public class WeightProbability
	{
		private var _cases : Vector.< SingleCase > = new Vector.< SingleCase >;
		
		private var _sum : Number = 0;
		
		
		public function Push( weight : Number, data : * ) : void
		{
			_cases.push( new SingleCase( weight, data ) );
			
			_sum += Math.abs( weight );
		}
		
		/** Randomly picks on of cases using it's weight and returns specified data for it.*/
		public function Resolve() : *
		{
			const point : Number = Math.random() * _sum;
			
			var currentSum : Number = 0;
			for ( var i : int = 0; i < _cases.length; ++i )
			{
				var singleCase : SingleCase = _cases[ i ];
				
				currentSum += singleCase._weight;
				if ( currentSum >= point )
				{
					return singleCase._data;
				}
			}
			
			Cc.error( "E: WeightProbability.Resolve(): no cases was specified. Returning null." );
			return null;
		}
		
		public function Clear() : void
		{
			for each ( var clearing : SingleCase in _cases )
			{
				clearing.Destroy();
			}
			_cases.length = 0;
			
			_sum = 0;
		}
	}

}


class SingleCase
{
	public var _weight : Number;
	public var _data : * ;
	
	
	public function SingleCase( weight : Number, data : * )
	{
		_weight = weight;
		_data = data;
	}
	
	public function Destroy() : void
	{
		_data = null;
	}
}


