///@cond
package view 
{
	
	///@endcond
	
	/** \sa Viewable
	Can switch it's view from time to time, keeping the same space (position), mouse interaction state (being clicked, hovered...) and so on.*/
	public interface Animated 
	{
		/** Stop any playing if there is some and start specified \b series (such as "walk", "idle", "shoot"...) or just start the animation if \b series is null.*/
		function Start( series:String = null ): void;
		
		/** Freeze the animation on current frame.*/
		function Stop(): void;
		
		/** Switch current frame to next. If animation is currently playing, stop it.*/
		function NextFrame(): void;
	}
	
}

