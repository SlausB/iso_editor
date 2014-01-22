///@cond
package project_data
{
	import flash.display.DisplayObject;
	import project_data.Resource;
	
	///@endcond
	
	/** Link to image (movie clip).*/
	public class SingleResource 
	{
		/** Where class of this resource are stored.*/
		public var _resourcePath : String;
		/** Class name within specified Resource.*/
		public var _name : String;
		
		
		public function Init( resourcePath : String, name : String ) : void
		{
			_resourcePath = resourcePath;
			_name = name;
		}
		
		/** Null if wasn't found.*/
		public function FindClass( project : Project ) : Class
		{
			var resource : Resource = project.FindResource( _resourcePath );
			if ( resource == null )
			{
				return null;
			}
			
			return resource._applicationDomain.getDefinition( _name ) as Class;
		}
		
		public function Display( project : Project ) : DisplayObject
		{
			return ( new ( FindClass( project ) as Class ) ) as DisplayObject;
		}
		
	}

}

