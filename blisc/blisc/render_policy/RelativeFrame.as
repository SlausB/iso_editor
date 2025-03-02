///@cond
package blisc.render_policy
{
	import blisc.core.BliscAnimation;
	import blisc.core.BliscSprite;
	import com.junkbyte.console.Cc;
	
	///@endcond
	
	
	/** Displaying single frame, but not .*/
	public class RelativeFrame extends RenderPolicy
	{
		public static const FIRST : int = 1;
		public static const LAST : int = 2;
		
		private var _which : int;
		
		
		public function RelativeFrame( which : int )
		{
			_which = which;
		}
		
		override public function DoIt( animation : BliscAnimation ) : BliscSprite
		{
			if ( animation._frames.length < 1 )
			{
				Cc.error( "E: RelativeFrame.DoIt(): no frames." );
				return null;
			}
			
			switch ( _which )
			{
				case FIRST:
					return animation._frames[ 0 ];
				
				case LAST:
					return animation._frames[ animation._frames.length - 1 ];
			}
			
			Cc.error( "E: RelativeFrame.DoIt(): which = " + _which.toString() + " is undefined." );
			
			return null;
		}
		
	}

}



