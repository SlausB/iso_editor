/// @cond
package fos 
{
	import flash.utils.ByteArray;
	/// @endcond
	
	/** Методика передачи данных на сервер.*/
	public class FosTransmitter 
	{
		/** Должен быть переопределён алгоритм подготовки данных для передачи на сервер.*/
		public function Wrap(data:ByteArray): ByteArray
		{
			return null;
		}
	}

}