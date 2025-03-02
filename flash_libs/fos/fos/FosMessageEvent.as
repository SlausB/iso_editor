package fos
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/** События получения от сервера целостного сообщения. Содержит в себе полностью данные в бинарном виде, полученные от сервера.*/
	public class FosMessageEvent extends Event
	{
		public static const FOS_MESSAGE:String = "fosMessage";
		
		private var _data:ByteArray;
		
		public function FosMessageEvent(newData:ByteArray)
		{
			super(FOS_MESSAGE);
			
			_data = newData;
		}
		
		public function get data(): ByteArray
		{
			return _data;
		}
		
		/** Возвращает копию данных, оставляя изначальные неизменными.*/
		public function Copy(): ByteArray
		{
			var dataCopy:ByteArray = new ByteArray;
			dataCopy.endian = Endian.LITTLE_ENDIAN;
			dataCopy.writeBytes(_data);
			dataCopy.position = 0;
			return dataCopy;
		}
	}
}

