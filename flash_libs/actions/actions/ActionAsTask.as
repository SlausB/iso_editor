/// @cond
package actions 
{
	
	/// @endcond
	
	/** \brief Простой вызов функции (действие) с параметрами внутри очереди.*/
	public class ActionAsTask extends Action
	{
		/** \brief Функция, вызываемая в Execute() */
		protected var task:Function;
		
		/** \brief С какими параметрами вызывать задание.*/
		public var argumentsAsActions:Vector.<Action> = new Vector.<Action>;
		
		/** \brief Время в секундах, на которое должно выполниться текущее действие.*/
		protected var elapsedSeconds:Number;
		
		/** \brief Сколько секунд потребило текущее действие.*/
		protected var consumedSeconds:Number;
		
		
		
		/** \brief Конструктор.
		\param task Функция, вызываемая в Execute() */
		public function ActionAsTask(output:Output, task:Function)
		{
			super(output);
			
			this.task = task;
		}
		
		override public function Clear():void 
		{
			task = null;
			for each(var argumentAsAction:Action in argumentsAsActions)
			{
				argumentAsAction.Clear();
			}
			argumentsAsActions.length = 0;
			
			super.Clear();
		}
		
		/** \brief Деструктор.
		\details Удаляются все AbstractData , хранящиеся в текущем действии.\n
		Будут удалены только те данные, которые представлены как Number. Об удалении остальных, увы, должен позаботиться сам пользователь.*/
		public function Delete(): void
		{
			DeleteValues();
			DeleteData();
		}
		
		/** \brief Создание своей копии.*/
		override public function MakeCopy(): Action
		{
			var copy:ActionAsTask = new ActionAsTask(output, task);
			copy.muteEnding = muteEnding;
			copy.solidarity = solidarity;
			copy.elapsedSeconds = elapsedSeconds;
			copy.consumedSeconds = consumedSeconds;
			//копирование параметров действия:
			for(var ia:int = 0; ia < argumentsAsActions.length; ia++)
			{
				copy.argumentsAsActions.push(argumentsAsActions[ia].MakeCopy());
			}
			//копирование данных:
			for(var id:int = 0; id < data.length; id++)
			{
				copy.data.push(data[id]);
			}
			
			return copy;
		}
		
		/** \brief Выполнится следующее: вызов Action.ResetToDefault() , очистка данных, удаление всех параметров и установка действия на Task_Default() .*/
		override public function ResetToDefault(): void
		{
			super.ResetToDefault();
			DeleteValues();
			DeleteData();
			abstractData.SetData( -1.0);
			task = Dispatcher.Task_Default;
		}
		
		/** \brief Сколько прошло времени в секундах с предыдущего вызова действия. Это время может быть потреблено текущим действием.
		\details Количество потреблённого действием времени указывать в Queue.ConsumedTime() .*/
		public function GetElapsedSeconds(): Number
		{
			return elapsedSeconds;
		}
		
		/** \brief Указание сколько времени затрачено на выполнение текущего действия.*/
		public function ConsumedSeconds(timeInSeconds:Number): void
		{
			//если потреблённым указано время, которое не давалось действию в распоряжение:
			if(timeInSeconds > (elapsedSeconds - consumedSeconds))
			{
				output.Out("W: ActionAsTask.ConsumedSeconds(" + timeInSeconds + "): consumed " + elapsedSeconds + " seconds but there are only " + (elapsedSeconds - consumedSeconds) + " seconds.\n", Output.WARN);
			}
			
			consumedSeconds += timeInSeconds;
		}
		
		
		/** \brief Данные, используемые в процессе выполнения задания. Массив объектов типа AbstractData .*/
		public var data:Vector.<AbstractData> = new Vector.<AbstractData>;
		
		
		
		/** \brief Вызов функции Task до тех пор, пока в ней не будет потреблено всё время либо пока действие не закончится.
		\sa Action::Execute() */
		override public function Execute(dispatcher:Dispatcher, consumeSeconds:Number): Number
		{
			//при испльзовании ActionGoTo проиходит зацикливания если между метками перехода существуют действия, выполняющиеся за один цикл, но, при этом, потребляющие время - обдумать их природу в дальнейшем:
			var childrenConsumedSeconds:Number = 0.0;
			
			//выполнение сначала всех параметров действий - после выполнения, должны сформироваться параметры, которые текущее действие может использовать:
			for(var i:int = 0; i < argumentsAsActions.length; i++)
			{
				const currentChildrenConsumtion:Number = argumentsAsActions[i].Execute(dispatcher, consumeSeconds);
				if (currentChildrenConsumtion > childrenConsumedSeconds) childrenConsumedSeconds = currentChildrenConsumtion;
				
				//если указано что нужно завершить выполнение действия если один из параметров завершил своё выполнение (при этом этому параметру должно быть разрешено завершать своё действие):
				if(solidarity)
				{
					if(dispatcher.queueOfCurrentAction.WasActionEnded())
					{
						//действие не потребило нисколько времени:
						return consumeSeconds;
					}
				}
			}
			
			//действие только начинает выполняться:
			consumedSeconds	= 0.0;
			
			//указываем что в данный момент активно текущее действие:
			dispatcher.queueOfCurrentAction.currentlyActiveAction = this;
			
			//вызов выполнения действия до тех пор, пока оно не употребит полностью всё время или не отметится как "оконченноe" (функцией Queue.ActionEnded()):
			do
			{
				//указываем сколько секунд действие может (и должно) потребить:
				elapsedSeconds = consumeSeconds - consumedSeconds;
				
				task(new Param(dispatcher, dispatcher.queueOfCurrentAction, this, argumentsAsActions));
				//если это действие "пытается" закончиться:
				if(dispatcher.queueOfCurrentAction.WasActionMarkedAsEnded()) break;
			}
			while(consumedSeconds < consumeSeconds);
			dispatcher.queueOfCurrentAction.OneCycleOfCurrentActionDone();
			
			//указываем сколько секунд потребило текущее действие:
			return consumedSeconds > childrenConsumedSeconds ? consumedSeconds : childrenConsumedSeconds;
		}
		
		/** \brief Удаление всех параметров ( values ).*/
		protected function DeleteValues(): void
		{
			//удаление всех Value:
			for(var i:int = 0; i < argumentsAsActions.length; i++)
			{
				delete argumentsAsActions[i];
			}
			argumentsAsActions.length = 0;
		}
		
		/** \brief Удаление всех абстрактных данных.*/
		protected function DeleteData(): void
		{
			data.length = 0;
		}
	}

}