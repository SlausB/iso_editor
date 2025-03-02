///@cond
package fos
{
	import com.junkbyte.console.Cc;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	
	///@endcond
	
	public class FosSimpleCollector implements FosCollector
	{
		public function Collect( from : IDataInput, handler : Function ) : void
		{
			//Cc.info( "I: FosSimpleCollector(): processing " + data.length + " bytes..." );
			//обработка всех целостных сообщений:
			for ( ;; )
			{
				//если даже нельзя прочитать размер получаемых данных, то пока ещё ничего сделать нельзя:
				if ( from.bytesAvailable < 4 )
				{
					break;
				}
				
				const messageSize : uint = from.readUnsignedInt();
				//если уже пришло полностью сообщение:
				if ( from.bytesAvailable >= messageSize )
				{
					var incomingData : ByteArray = new ByteArray;
					incomingData.endian = Endian.LITTLE_ENDIAN;
					from.readBytes( incomingData, 0, messageSize );
					handler( incomingData );
				}
				else
				{
					break;
				}
				
				//продолжаем читать другие сообщения, которые могли придти в скупе с уже прочитанными...
			}
		}
	}

}