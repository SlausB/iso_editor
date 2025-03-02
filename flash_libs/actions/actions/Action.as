/// @cond
package actions 
{
	
	/// @endcond
	
	/** \brief Абстрактный класс действия внутри очереди.*/
	public class Action 
	{
		/** Средство вывода отладочной информации. Передаётся в конструкторе.*/
		public var output:Output;
		
		/** \brief Значение, сформированное в последнем вызове Execute() если это ActionAsTask или просто хранящиеся данные если это ActionAsData .*/
		protected var abstractData:AbstractData;
		
		/** \brief Если установлено в true (по умолчанию false), то все попытки действия сообщить очереди что оно закончено (через Queue.ActionEnded() ) будут игнорироваться.*/
		public var muteEnding:Boolean;
		
		/** \brief Если установлено в true (по-умолчанию true), то действие не будет выполнять свой цикл если одно из его действий-параметров закончило своё выполнение (или было отмечено как действие, которое "хочет" завершиться).
		\sa Actions.Queue.WasActionMarkedAsEnded() */
		public var solidarity:Boolean;
		
		
		/** \brief Конструктор. Устанавливает muteEnding в false.*/
		public function Action(output:Output)
		{
			this.output = output;
			
			muteEnding = false;
		}
		
		/** Очистка. В попытке устранить утечки памяти.*/
		public function Clear(): void
		{
			abstractData = null;
		}
		
		/** \brief Создание своей копии.
		\details Используется при создании действия из ActionDesc , а также при копировании очередей. Определяется в наследниках.*/
		public function MakeCopy(): Action
		{
			output.Out("E: Action.MakeCopy(): called pure virtual function.\n", Output.ERROR);
			
			return null;
		}
		
		/** \brief Получение значения как результат последнего выполнения Execute() .
		\details Может вызываться много раз внутри одного цикла.*/
		public function GetData(): AbstractData
		{
			return abstractData;
		}
		
		/** \brief Установка данных, как результат выполнения задания.
		\details Обычно устанавливается в задании.*/
		public function SetData(abstractData:AbstractData): void
		{
			this.abstractData = abstractData;
		}
		
		/** \brief Установка muteEnding в false.*/
		public function ResetToDefault(): void
		{
			muteEnding = false;
		}
		
		/** \brief Установить muteEnding .
		\sa muteEnding */
		public function SetMuteEnding(muteEnding:Boolean): void
		{
			this.muteEnding = muteEnding;
		}
		
		/** \brief Получить muteEnding .
		\sa muteEnding */
		public function GetMuteEnding(): Boolean
		{
			return muteEnding;
		}
		
		
		
		/** \brief Вызывается очередью, в которой хранится это задание.
		\details Должно вызываться один раз в рамках одного цикла. Определяется в наследниках.
		\param dispatcher Диспетчер, в котором выполняется это действие.
		\param consumeSeconds Время в секундах, которое <b>должно</b> быть потреблено действием. Функция действия будет вызываться до тех пор, пока это время не будет полностью потреблено или пока действие не завершится.
		\return Сколько секунд действие потребило.*/
		public function Execute(dispatcher:Dispatcher, consumeSeconds:Number): Number
		{
			output.Out("E: Action.Execute(): called pure virtual function.\n", Output.ERROR);
			
			return 0.0;
		}
		
	}

}