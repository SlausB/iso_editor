package fos 
{
	import flash.utils.ByteArray;
	
	public interface FosDataHandler 
	{
		function HandleCollectedData( data:ByteArray ): void;
	}

}