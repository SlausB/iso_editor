///@cond
package project_data
{
	import flash.system.ApplicationDomain;
	///@endcond
	
	/** SWF file with graphical resources.*/
	public class Resource 
	{
		public var _path:String;
		
		public var _applicationDomain:ApplicationDomain;
		
		/** [ String ].*/
		public var _names:Array;
		
		
		public function Init( applicationDomain:ApplicationDomain, names:Array ): void
		{
			_applicationDomain = applicationDomain;
			
			_names = names;
		}
		
	}

}

