/// @cond
package actions 
{
	
	/// @endcond
	
	/** \brief Очередь выполняемых действий.*/
	public class Queue 
	{
		/** \brief Средство вывода отладочных сообщений. Передаётся в конструкторе.*/
		private var output:Output;
		
		/** \brief Действия.*/
		private var _actions:Vector.<Action> = new Vector.<Action>;
		
		/** \brief Индекс текущего действия.*/
		public var currentAction:int;
		
		/** \brief Закончилось ли текущее действие в очереди.
		\details Устанавливается в true в ActionEnded() .*/
		public var wasActionEnded:Boolean;
		
		/** \brief Действие, которое выполняется в данный момент.
		\details По завершении выполнения действия или между циклами указатель становится неактуальным, поэтому используется только в функциях интерфейса выполняемого действия с очередью, в которой это действие находится.
		Устанавливается в Dispatcher.Live() .*/
		public var currentlyActiveAction:Action;
		
		/** \brief Пометило ли текущее действие себя как "оконченное".
		\details Для того чтобы действие действительно закончилось нужно чтобы внутри него переменная muteEnding была равна false.\n
		Будет установлено в true и в том случае, если действие закончилось.
		\sa Actions.Queue.ActionEnded() */
		public var wasActionMarkedAsEnded:Boolean;
		
		/** \brief true - после завершения текущего действия очередь сохранит это действия как снова "текущее". Сбрасывается после одного использования.
		\details То есть после своего завершения действия снова начнёт выполняться с нуля. Сбрасывается после одного использования.*/
		public var remainOnCurrentAction:Boolean;
		
		
		
		/** \brief Конструктор.
		\param output Средство вывода отладочных сообщений.*/
		public function Queue(output:Output)
		{
			this.output = output;
			
			SetDataToDefault();
		}
		
		/** \brief Конструктор.
		\details Копирование указанных данных.
		\param queue Очередь, которую нужно скопировать.*/
		public function Copy(queue:Queue): void
		{
			//если указатель неверный, то вызываем обычный конструктор:
			if (queue == null)
			{
				SetDataToDefault();
				return;
			}
			
			currentAction = queue.currentAction;
			
			//создание и копирование всех действий:
			for(var i:int = 0; i < queue._actions.length; i++)
			{
				_actions.push(queue._actions[i].MakeCopy());
			}
			
			wasActionEnded = queue.wasActionEnded;
			wasActionMarkedAsEnded = queue.wasActionMarkedAsEnded;
			
			doneCycles = queue.doneCycles;
			
			remainOnCurrentAction = queue.remainOnCurrentAction;
		}
		
		/** \brief Текущее действие.
		\return Указатель на текущее действие. null если действий нет или все действия выполнены.*/
		public function CurrentAction(): Action
		{
			if(currentAction < 0 || currentAction >= _actions.length) return null;
			return _actions[currentAction];
		}
		
		/** \brief Текущее действие закончилось.
		\details Используется в действиях для указания что оно закончилось.\n
		Это лишь указание на то что действие закончилось. Перевод указателя Actions.Queue.currentAction и другие операции будут выполнены только когда управление вернётся функции Actions.Dispatcher.Live() (то есть когда завершится действие, вызвавшее эту функцию и/или действие, которое хранит внутри себя это действие как аргумент).*/
		public function ActionEnded(): void
		{
			//действие однозначно должно быть помечено как "оконченное":
			wasActionMarkedAsEnded = true;
			
			//"по-настоящему" окончить действие можно только если это разрешено:
			if(currentlyActiveAction.GetMuteEnding() == false)
			{
				output.Out("I: Queue.ActionEnded(): action was settled to ended.\n", Output.INFO);
				wasActionEnded = true;
			}
			else
			{
				output.Out("I: Queue.ActionEnded(): action is trying to end but it is muted. It was just MARKED as ended.\n", Output.INFO);
			}
		}
		
		/** \brief Закончилось ли текущее действие.*/
		public function WasActionEnded(): Boolean
		{
			return wasActionEnded;
		}
		
		/** \brief Возвращает wasActionMarkedAsEnded .
		\details Используется в ActionAsTask.Execute() для определения когда прекратить вечный вызов выполнения задания (помимо определения величины потреблённого времени).*/
		public function WasActionMarkedAsEnded(): Boolean
		{
			return wasActionMarkedAsEnded;
		}
		
		/** \brief Добавление нового действия.*/
		public function AddAction(action:Action): void
		{
			_actions.push(action);
			
			//если до этого были совершены все действия, то перенаправляем указатель текущего действия на только что добавленное действие - в этом случае в Live() будет выполняться оно:
			if(currentAction < 0 || currentAction >= _actions.length)
			{
				currentAction = _actions.length - 1;
			}
		}
		
		/** \brief Удаление всех действий.*/
		public function Clear(): void
		{
			//удаление всех действий:
			for each(var action:Action in _actions)
			{
				action.Clear();
			}
			
			//очистка массива указателей на действия:
			_actions.length = 0;
			
			SetDataToDefault();
		}
		
		/** \brief Перевод указателя текущего действия на указанное действие.
		\param actionIndex Индекс действия, на которое нужно перевести указатель.*/
		public function GoToAction(actionIndex:int): void
		{
			output.Out("I: Queue.GoToAction(): actionIndex = " + actionIndex + ".\n", Output.INFO);
			
			if(actionIndex < 0)
			{
				output.Out("E: Queue.GoToAction(): actionIndex = " + actionIndex + ". It must be at least positive.\n", Output.ERROR);
				return;
			}
			
			if(actionIndex >= _actions.length)
			{
				output.Out("W: Queue.GoToAction(): actionIndex = " + actionIndex + ". There are only " + _actions.length + " actions. Skipping all actions.\n", Output.WARN);
				
				actionIndex	= _actions.length;
			}
			
			//фактический переход на указанное действие:
			currentAction = actionIndex;
			
			//ещё не было выполнено ни одного цикла текущего действия:
			doneCycles = 0;
			
			output.Out("I: Queue.GoToAction(): currentAction was settled to " + currentAction + ".\n", Output.INFO);
		}
		
		/** \brief Количество действий.*/
		public function ActionsCount(): int
		{
			return _actions.length;
		}
		
		/** \brief Должно вызываться действием после совершения действия.
		\details Если действие пришлось вызвать несколько раз, то эту функцию вызвать после <b>всех</b> вызовов.*/
		public function OneCycleOfCurrentActionDone(): void
		{
			wasActionMarkedAsEnded = false;
		}
		
		/** \brief Установка remainOnCurrentAction .
		\sa remainOnCurrentAction */
		public function SetRemainOnCurrentAction(remainOnCurrentAction:Boolean): void
		{
			this.remainOnCurrentAction = remainOnCurrentAction;
		}
		
		/** \brief Получение remainOnCurrentAction .
		\sa remainOnCurrentAction */
		public function GetRemainOnCurrentAction(): Boolean
		{
			return remainOnCurrentAction;
		}
		
		
		/** \brief Установка данных на по-умолчанию.*/
		private function SetDataToDefault(): void
		{
			currentAction = 0;
			
			wasActionEnded = false;
			wasActionMarkedAsEnded = false;
			
			doneCycles = 0;
			
			remainOnCurrentAction = false;
		}
		
		
		/** \brief Сколько циклов выполняется текущее действие.
		\details Увеличивается диспетчером в Live() .*/
		public var doneCycles:int;
		
		/** \brief Данные, которые устанавливаются и читаются в действиях текущей очереди.*/
		public var associativeArray:Array = [];
		
	}

}