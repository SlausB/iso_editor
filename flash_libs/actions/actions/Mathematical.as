/// @cond
package actions 
{
	/// @endcond
	
	/** Действия, связанные с математическими операциями.*/
	public class Mathematical 
	{
		/** \brief Получить синус угла, указанного в градусах.
		\details \anchor Size
		- <span style="color:#ff0000"><b>1</b></span> Угол в градусах.*/
		public static function Sine(param:Param): void
		{
			/** \brief Угол в градусах.*/
			const A_ANGLE:int = 0;
			
			if (Dispatcher.CheckArguments("Sine", param, 1)) return;
			
			const angle:Number = param.argumentsAsActions[A_ANGLE].GetData().AsFloat();
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(Math.sin(angle / 57.295779513082320876798154814105)));
			
			//действие однозначно заканчивается:
			param.queue.ActionEnded();
		}
		
		/** \brief The same as Math.floor().
		\details \anchor Floor
		- <span style="color:#ff0000"><b>1</b></span> Any Number (or int - doesn't matter).*/
		public static function Floor( param : Param ) : void
		{
			if ( Dispatcher.CheckArguments( "Floor", param, 1 ) )
			{
				return;
			}
			
			const value : Number = param.argumentsAsActions[ 0 ].GetData().AsFloat();
			
			param.action.SetData( new AbstractData( Math.floor( value ) ) );
			
			param.queue.ActionEnded();
		}
	}

}

