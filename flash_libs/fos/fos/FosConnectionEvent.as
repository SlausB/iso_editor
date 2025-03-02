package fos
{
	import flash.events.Event;
	
	/** Событие подключения к серверу.*/
	public class FosConnectionEvent extends Event
	{
		public static const FOS_CONNECTION:String = "fosConnection";
		
		public function FosConnectionEvent()
		{
			super(FOS_CONNECTION);
		}
	}
}

