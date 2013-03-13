///@cond
package edit_space 
{
	///@endcond
	
	public class ColorCollection 
	{
		public var _color:uint;
		public var _groups:Vector.< int >;
		
		public function ColorCollection( color:uint, groups:Vector.< int > = null )
		{
			_color = color;
			
			if ( groups == null )
			{
				_groups = new Vector.< int >;
			}
			else
			{
				_groups = groups;
			}
		}
	}

}

