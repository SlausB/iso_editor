///@cond
package
{
	
	///@endcond
	
	
	/** Used while resources data publishing.*/
	public class AnimationDesc
	{
		/** Unified id to rapidly lookup and differentiate animations.*/
		public var _id : int;
		
		public var _name : String;
		
		public var _editorsPath : String;
		
		public var _startingFrame : int;
		public var _endingFrame : int;
		
		
		public function AnimationDesc( id : int, name : String, editorsPath : String, startingFrame : int, endingFrame : int )
		{
			_id = id;
			
			_name = name;
			
			_editorsPath = editorsPath;
			
			_startingFrame = startingFrame;
			_endingFrame = endingFrame;
		}
		
	}

}



