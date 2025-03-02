/// @cond
package actions 
{
	
	/// @endcond
	
	/** \brief Простое значение как параметр (аргумент) для задания (действия).
	\details В отличие от ActionAsTask представляет из себя простое значение, которое не изменяется на протяжении всего выполнения действия.*/
	public class ActionAsData extends Action
	{
		/** \brief Конструктор.
		\details Обязательная установка значения.*/
		public function ActionAsData(output:Output, abstractData:AbstractData)
		{
			super(output);
			
			this.abstractData = abstractData;
		}
		
		/** \brief Создание своей копии.*/
		override public function MakeCopy(): Action
		{
			var action:ActionAsData = new ActionAsData(output, abstractData);
			action.muteEnding = muteEnding;
			action.solidarity = solidarity;
			return action;
		}
		
		
		/** \brief Вызывается очередью, в которой хранится это задание.
		\details Должна вызываться один раз в рамках одного цикла.\n
		Просто указывается что было потреблено всё время.
		\return В ActionAsData указывается что было потреблено всё время (возвращается consumeSeconds ).*/
		override public function Execute(dispatcher:Dispatcher, consumeSeconds:Number): Number
		{
			return consumeSeconds;
		}
	}

}