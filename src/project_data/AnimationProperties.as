///@cond
package project_data
{
	
	///@endcond
	
	
	/** \sa BliscAnimationTemplate .*/
	public class AnimationProperties
	{
		public var _editorsPath : String;
		public var _animationName : String;
		
		public var _eachFrame : int;
		
		
		public function Init( editorsPath : String, animationName : String, eachFrame : int ) : void
		{
			_editorsPath = editorsPath;
			_animationName = animationName;
			
			_eachFrame = eachFrame;
		}
	}

}



