///@cond
package view 
{
	
	///@endcond
	
	/** How display objects - within which space, at which viewport (screen).
	"Space" is something where graphical objects "inhabit" while "View" is the screen (which is mostrly two-dimensional).
	We are not so smart as Hamilton, our world consists only or 3 coordinates instead of 4.*/
	public class Projection 
	{
		public function X_FromSpaceToView( x:Number ): Number
		{
			return x;
		}
		public function X_FromViewToSpace( x:Number ): Number
		{
			return x;
		}
		
		public function Y_FromSpaceToView( y:Number ): Number
		{
			return y;
		}
		public function Y_FromViewToSpace( y:Number ): Number
		{
			return y;
		}
		
		public function Z_FromSpaceToView( z:Number ): Number
		{
			return z;
		}
		public function Z_FromViewToSpace( z:Number ): Number
		{
			return z;
		}
	}

}

