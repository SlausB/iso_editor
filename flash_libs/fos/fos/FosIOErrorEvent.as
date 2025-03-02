package fos
{
	import flash.events.Event;
	
	public class FosIOErrorEvent extends Event
	{
		public static const FOS_IOERROR:String = "fosIOError";
		
		public function FosIOErrorEvent()
		{
			super(FOS_IOERROR);
		}
	}
}

