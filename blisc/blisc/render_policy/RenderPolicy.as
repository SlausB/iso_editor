///@cond
package blisc.render_policy
{
	import blisc.core.BliscAnimation;
	import blisc.core.BliscSprite;
	import com.junkbyte.console.Cc;
	
	///@endcond
	
	
	/** Used in ObjectRenderer to specify how object must be rendered.*/
	public class RenderPolicy
	{
		public function DoIt( animation : BliscAnimation ) : BliscSprite
		{
			Cc.error( "E: RenderPolicy.DoIt(): virtual function call." );
			return null;
		}
	}

}

