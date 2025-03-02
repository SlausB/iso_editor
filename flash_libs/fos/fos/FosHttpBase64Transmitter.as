/// @cond
package fos 
{
	import flash.utils.ByteArray;
	
	/// @endcond
	
	public class FosHttpBase64Transmitter extends FosTransmitter
	{
		override public function Wrap( data:ByteArray ): ByteArray
		{
			var result:ByteArray = new ByteArray;
			result.endian = data.endian;
			var encoded:String = Base64.encode( data );
			result.writeUTF("HTTP/1.1 GET \r\nContent-Type: text/plain\r\nContent-Length: " + encoded.length + "\r\n\r\n" + encoded);
			return result;
		}
	}

}