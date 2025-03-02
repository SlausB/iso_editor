package fos
{
	import flash.events.Event;
	
	/** Событие отключения от сервера.*/
	public class FosDisconnectionEvent extends Event
	{
		public static const FOS_DISCONNECTION:String = "fosDisconnection";
		
		public function FosDisconnectionEvent()
		{
			super(FOS_DISCONNECTION);
		}
	}
}

