/// @cond
package fos 
{
	import com.junkbyte.console.Cc;
	import fos.FosClient;
	import flash.utils.ByteArray;
	/// @endcond
	
	/** Чтение закодированных посредством base64 бинарных данных в виде HTTP-пакета.*/
	public class FosHttpBase64Collector implements FosCollector
	{
		public function Collect( data:ByteArray, handler:Function ):void 
		{
			for (;; )
			{
				var haveRead:Boolean = false;
				var tempReadBuffer:String = data.readUTFBytes( data.length );
				data.position = 0;
				
				//прочитанный (если хватает байт) размер в байтах входящего сообщения:
				var messageSize:int = -1;
				
				//ищем параметр "Content-Length" в загаловке:
				var what:String = "Content-Length: ";
				var whatPtr:int = 0;
				for(var pos:int = 0; pos < tempReadBuffer.length; pos++)
				{
					if ( whatPtr >= what.length )
					{
						const valuePos:int = pos;
						for ( var endPos:int = pos; endPos < tempReadBuffer.length; ++endPos )
						{
							if ( tempReadBuffer.charCodeAt( endPos ) == 13/*'\r'*/ )
							{
								messageSize = parseInt( tempReadBuffer.slice( pos, endPos ) );
								break;
							}
						}
						break;
					}
					else
					{
						if ( what.charCodeAt( whatPtr ) == tempReadBuffer.charCodeAt( pos ) )
							whatPtr++;
						else
							whatPtr = 0;
					}
				}
				
				
				//данные начинаются после пустой строки:
				if ( messageSize >= 0 )
				{
					var starting:int = -1;
					for ( var p:int = 3; p < tempReadBuffer.length; ++p )
					{
						//13 = '\r', 10 = '\n':
						if ( tempReadBuffer.charCodeAt( p - 3 ) == 13 && tempReadBuffer.charCodeAt( p - 2 ) == 10 && tempReadBuffer.charCodeAt( p - 1 ) == 13 && tempReadBuffer.charCodeAt( p ) == 10 )
						{
							starting = p + 1;
							break;
						}
					}
					
					//если начало данныйх уже получено и получено достаточно данных чтобы прочитать все их из текущего пакета:
					if ( starting >= 0 && tempReadBuffer.length >= ( starting + messageSize ) )
					{
						var decoded:ByteArray = Base64.decode( tempReadBuffer.slice( starting, starting + messageSize ) );
						decoded.endian = data.endian;
						decoded.position = 0;
						handler( decoded );
						
						//отбрасываем полностью переданное сообщение:
						//не знаю как поведёт себя ByteArray если читать данные из него в него же, поэтому не будем рисковать:
						var remainder:ByteArray = new ByteArray;
						//тоже LITTLE_ENDIAN для того чтобы _data сохранило это свойство после копирования в него остатка:
						remainder.endian = data.endian;
						data.position = starting + messageSize;
						data.readBytes( remainder );
						data.clear();
						remainder.readBytes( data );
						data.position = 0;
						
						haveRead = true;
					}
				}
				
				if ( !haveRead )
					break;
			}
		}
	}

}