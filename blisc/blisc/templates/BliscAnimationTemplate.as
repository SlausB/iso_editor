///@cond
package blisc.templates
{
	
	///@endcond
	
	
	/** Describes properties manually assigned to animation. Some animations have no properties assigned.*/
	public class BliscAnimationTemplate
	{
		/** Animations library path to resolve animation.*/
		public var _editorsPath : String;
		/** Animation's name to resolve it.*/
		public var _name : String;
		
		/** Which frames this animation must consist from. First frame is "1", not "0".*/
		public var _frames : Vector.< int >;
		
		
		public function BliscAnimationTemplate( editorsPath : String, name : String, frames : Vector.< int > )
		{
			_editorsPath = editorsPath;
			_name = name;
			
			_frames = frames;
		}
		
	}

}



