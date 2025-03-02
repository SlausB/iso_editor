/// @cond
package fos 
{
	import flash.utils.ByteArray;
	
	/// @endcond
	
	public class FosLeb128Transmitter extends FosTransmitter
	{
		override public function Wrap(data:ByteArray): ByteArray
		{
			var result:ByteArray = new ByteArray;
			result.endian = data.endian;
			var length:uint = data.length;
			do
			{
				var byte:int = length & 0x7F;
				length >>= 7;
				if (length != 0) /* more bytes to come */
				{
					byte |= 0x80;
				}
				result.writeByte(byte);
			}
			while (length != 0);
			result.writeBytes(data);
			return result;
		}
	}

}