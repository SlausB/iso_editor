///@cond
package ie
{
	import mx.controls.Alert;
	
	///@endcond
	
	
	/** Shoes default for this project pop up window.*/
	public class PopUp 
	{
		public static const POP_UP_INFO : int = 1;
		public static const POP_UP_WARNING : int = 2;
		public static const POP_UP_ERROR : int = 3;
		
		[ Embed( source = "../info_icon.png" ) ]
		private static var _infoIconClass : Class;
		[ Embed( source = "../warning_icon.png" ) ]
		private static var _warningIconClass : Class;
		[ Embed( source = "../error_icon.png" ) ]
		private static var _errorIconClass : Class;
		
		/**
		\param type One of upperly predefined constants.
		*/
		public static function Show( message : String, type : int ) : void
		{
			var iconClass : Class = _infoIconClass;
			var title : String = "Info";
			switch ( type )
			{
				case POP_UP_WARNING:
					iconClass = _warningIconClass;
					title = "Warning";
					break;
				
				case POP_UP_ERROR:
					iconClass = _errorIconClass;
					title = "Error";
					break;
			}
			Alert.show( message, title, Alert.OK, null, null, iconClass );
		}
	}

}

