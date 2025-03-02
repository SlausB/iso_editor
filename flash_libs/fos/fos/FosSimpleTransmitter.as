/// @cond
package fos 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/// @endcond
	
	/** Обычное предварение данных 32-битных числовым значением их длины.*/
	public class FosSimpleTransmitter extends FosTransmitter
	{
		override public function Wrap(data:ByteArray): ByteArray
		{
			var result:ByteArray = new ByteArray;
			result.endian = data.endian;
			result.writeUnsignedInt(data.length);
			result.writeBytes(data);
			return result;
		}
	}

}