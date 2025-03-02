package fos
{
	import flash.events.Event;
	
	public class FosTraceEvent extends Event
	{
		public static const FOS_TRACE:String = "fosTrace";
		
		private var _kind:int;
		private var _message:String;
		
		public static const INFO:int = 0;
		public static const TRACE:int = 1;
		public static const DEBUG:int = 2;
		public static const TODO:int = 3;
		public static const WARN:int = 4;
		public static const ERROR:int = 5;
		public static const FATAL:int = 6;
		
		public function FosTraceEvent(kind:int, message:String)
		{
			super(FOS_TRACE);
			
			_kind = kind;
			_message = message;
		}
		
		public function get kind(): int
		{
			return _kind;
		}
		
		public function get message(): String
		{
			return _message;
		}
	}
}

