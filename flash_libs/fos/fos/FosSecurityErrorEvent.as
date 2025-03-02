///@cond
package fos
{
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	
	///@endcond
	
	public class FosSecurityErrorEvent extends Event
	{
		public static const FOS_SECURITYERROR : String = "fosSecurityError";
		
		public var _e : SecurityErrorEvent;
		
		
		public function FosSecurityErrorEvent( e : SecurityErrorEvent )
		{
			super( FOS_SECURITYERROR );
			
			_e = e;
		}
	}
}



