/// @cond
package actions 
{
	
	/// @endcond
	
	/** \brief Используется для описания действия перед добавлением в очередь.*/
	public class ActionDesc 
	{
		/** Средство вывода отладочной информации. Передаётся в конструкторе.*/
		private var output:Output;
		
		
		/** \brief Конструктор по-умолчанию.*/
		public function ActionDesc(output:Output)
		{
			this.output = output;
			
			ResetToDefault();
		}
		
		/** \brief Обнуление дескриптора и добавление задания с указанными параметрами.
		\param task Какое задание выполнять.
		\param args \sa Push */
		public function To(task:Function, ... args): void
		{
			Clear();
			
			this.task = task;
			
			for (var i:int = 0; i < args.length; i++)
			{
				ProcessArgument(i, args[i]);
			}
		}
		
		/** \brief Добавление параметров, с которыми вызывать задание.
		\param args Параметры, каждый из которых может иметь следующие типы:\n
			- Number или Int - параметр, который будет преобразован в AbstractData и передан в Task
			- ActionDesc - изменяемый параметр (тоже является действием)
			- AbstractData - данные произвольного типа. Обычно используется для передачи данным типа void*. В таком случае действие, которое считывает этот параметр, должно правильным образом использовать эти данные.
			- любое другое - преобразовывается в AbstractData
		*/
		public function Push(... args): void
		{
			for (var i:int = 0; i < args.length; i++)
			{
				ProcessArgument(argumentsAsActions.length + i, args[i]);
			}
		}
		
		/** \brief Установить указанный аргумент на указанный индекс.
		\details \sa Push */
		private function ProcessArgument(index:int, value:*): void
		{
			if (value is ActionDesc)
			{
				var actionDesc:ActionDesc = value as ActionDesc;
				argumentsAsActions[index] = actionDesc.CreateAction();
			}
			else
			{
				var abstractData:AbstractData;
				if (value is Number)
				{
					abstractData = new AbstractData(value as Number);
				}
				else if (value is int)
				{
					abstractData = new AbstractData(value as int);
				}
				else
				{
					abstractData = new AbstractData;
					abstractData.SetData(value);
				}
				argumentsAsActions[index] = new ActionAsData(output, abstractData);
			}
		}
		
		/** \brief Установка значения конкретного аргумента.
		\details \sa Push */
		public function SetArgument(index:int, value:*): void
		{
			if(index < 0)
			{
				output.Out("E: ActionDesc.SetArgument(): index = " + index + " is wrong. It have to be more then 0 at least. Returning.\n", Output.ERROR);
				return;
			}
			
			ProcessArgument(index, value);
		}
		
		/** \brief Создание новых действий, идентичных действиям, в копируемом дескрипторе.*/
		public function Copy(actionDesc:ActionDesc): void
		{
			DeleteValues();
			
			task = actionDesc.task;
			for(var i:int = 0; i < actionDesc.argumentsAsActions.length; i++)
			{
				argumentsAsActions.push(actionDesc.argumentsAsActions[i].MakeCopy());
			}
			
			muteEnding = actionDesc.muteEnding;
			solidarity = actionDesc.solidarity;
		}
		
		/** \brief Очистка.
		\details Удаление всех values и установка всех параметров на по-умолчанию.*/
		public function Clear(): void
		{
			DeleteValues();
			
			ResetToDefault();
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
		
		/** \brief Установка всех значений на по-умолчанию.*/
		public function ResetToDefault(): void
		{
			task = Dispatcher.Task_Default;
			muteEnding = false;
			solidarity = false;
		}
		
		/** \brief Установка solidarity .
		\sa solidarity */
		public function SetSolidarity(solidarity:Boolean): void
		{
			this.solidarity = solidarity;
		}
		
		/** \brief Получение solidarity .
		\sa solidarity */
		public function GetSolidarity(): Boolean
		{
			return solidarity;
		}
		
		/** \brief Создание действия из сформированных задания и параметров.*/
		public function CreateAction(): Action
		{
			var actionAsTask:ActionAsTask = new ActionAsTask(output, task);
			actionAsTask.muteEnding = muteEnding;
			actionAsTask.solidarity = solidarity;
			//копирование параметров действия:
			for(var i:int = 0; i < argumentsAsActions.length; i++)
			{
				actionAsTask.argumentsAsActions.push(argumentsAsActions[i].MakeCopy());
			}
			return actionAsTask;
		}
		
		/** \brief Удаление всех параметров ( values ).*/
		public function DeleteValues(): void
		{
			for(var i:int = 0; i < argumentsAsActions.length; i++)
			{
				delete argumentsAsActions[i];
			}
			argumentsAsActions.length = 0;
		}
		
		/** \brief Установленное задание.
		\details По-умолчанию равно Task_Default .*/
		public var task:Function;
		/** \brief Добавленные аргументы, с которыми вызывать задание.*/
		public var argumentsAsActions:Array = [];
		
		/** \brief Если установлено в true (по-умолчанию false), то все попытки действия сообщить очереди что оно закончено (через Queue::ActionEnded() ) будут игнорироваться.*/
		public var muteEnding:Boolean;
		
		/** \brief Завершить выполнение действия и оставшихся аргументов если один из аргументов завершил своё выполнение.
		\details Если установлено в true (по-умолчанию true), то действие не будет выполнять свой цикл если одно из его действий-параметров закончило своё выполнение (при этом параметру <b>должно</b> быть разрешено завершать действие (см. Action.muteEnding ).\n
		Перед вызовом самого действия его параметры выполняются слева-направо, поэтому после того как один из параметров завершит своё выполнение, то (если solidarity = true) остальные параметры, также как и это действие, выполняться <b>не</b> будут.\n
		\sa Queue.WasActionEnded() */
		public var solidarity:Boolean;
	}

}