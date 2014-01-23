///@cond
package project_data
{
	
	///@endcond
	
	
	/** \sa BliscAnimationTemplate .*/
	public class AnimationProperties
	{
		public var _editorsPath : String;
		public var _animationName : String;
		
		/** Which each frame resulting animation must have. Say, original animation has frames '1, 2, 3, 4, 5, 6, 7, 8', if 'each value' is set to 3, then resulting animation will be '1, 4, 7'. Time gaps will be properly keepen (time to play '1, 4, 7' animation will be the same as '1, 2, 3, 4, 5, 6, 7, 8'.*/
		public var _eachFrame : int;
		
		
		public function Init( editorsPath : String, animationName : String, eachFrame : int ) : void
		{
			_editorsPath = editorsPath;
			_animationName = animationName;
			
			_eachFrame = eachFrame;
		}
	}

}



