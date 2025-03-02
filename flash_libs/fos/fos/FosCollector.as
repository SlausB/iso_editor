package fos 
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	public interface FosCollector 
	{
		/** 
		\param handler function( data : ByteArray ) : void .*/
		function Collect( from : IDataInput, handler : Function ) : void;
	}

}


