package utils 
{
	/** Пароль для ввода с клавиатуры.*/
	public class Password 
	{
		private var _password:String;
		private var _entered:String = "";
		
		
		public function Password(password:String)
		{
			this._password = password;
		}
		
		/** Ввести очередной символ как элемент пароля.
		onKeyBoardEvent(e:KeyboardEvent): void
		{
			if ( password.PassKey( String.fromCharCode( e.charCode ) ) )
			{
				//password passed...
			}
		}
		\return true если пароль был введён полностью и корректно.
		.*/
		public function PassKey(char:String): Boolean
		{
			if ( _password.length <= 0 )
				return true;
			
			_entered = _entered.concat(char);
			//введёная строка достигла длины пароля - можно сравнивать:
			if ( _entered.length >= _password.length )
			{
				//совпадение:
				if ( _entered == _password )
				{
					//сброс для следующего ввода (пусть начинается сначала, если пароль - это некое периодическое повторение слов):
					_entered = "";
					return true;
				}
				//нет совпадения - будем высматривать его после введения следующего символа:
				_entered = _entered.slice(1, _entered.length);
				return false;
			}
			//введёная строка ещё недостаточной длины:
			return false;
		}
		
	}

}