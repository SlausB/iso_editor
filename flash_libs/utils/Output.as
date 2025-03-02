/// @cond
package  
{
	
	/// @endcond
	
	/** Средство вывода отладочной информации.*/
	public class Output 
	{
		public static const INFO : int = 0;
		public static const TRACE : int = 1;
		public static const DEBUG : int = 2;
		public static const TODO : int = 3;
		public static const WARN : int = 4;
		public static const ERROR : int = 5;
		public static const FATAL : int = 6;
		
		
		private var _onOut : Function;
		
		/** Конструктор.
		\param onOut function( what : String, type : int ) : void вызывается при необходимости вывести информацию, где what - текст для вывода, а type - тип информации из констант.*/
		public function Output( onOut : Function )
		{
			_onOut = onOut;
		}
		
		public function Out( what : String, type : int) : void
		{
			_onOut( what, type );
		}
		
	}

}



