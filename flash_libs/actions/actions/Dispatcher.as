/// @cond
package actions
{
	import actions.Action;
	import actions.ActionAsTask;
	import actions.ActionCreationResult;
	import actions.ActionDesc;
	import actions.Queue;
	
	/// @endcond
	
	/** \brief Хранит очереди. Вызывает выполнение их действий.*/
	public class Dispatcher 
	{
		/** Куда выводится вся информация. Указывается в конструкторе.*/
		private var output:Output;
		
		/** \brief Очереди, которые в данный момент игнорируются.*/
		private var ignoringQueues:Array = [];
		
		/** \brief Потоки вызовов функции Live(), которые в данный момент игнорируются.*/
		private var ignoringThreads:Array = [];
		
		/** \brief Массив очередей.*/
		private var queues:Array = [];
		
		/** \brief Перенаправление на индекс по идентификатору для каждой очереди.*/
		private var redirections:Array = [];
		
		/** \brief Очередь, в которой выполняется текущее действие. Имеет смысл использовать только внутри какого-либо действия.*/
		public var queueOfCurrentAction:Queue = null;
		
		
		
		
		/** Действие по умолчанию.*/
		public static function Task_Default(param:Param): void
		{
			param.queue.ActionEnded();
		}
		
		
		
		/** Конструктор.
		\param output Куда будет выводиться вся информация о ходе выполнения действий и прочем.*/
		public function Dispatcher(output:Output): void
		{
			this.output = output;
		}
		
		/** \brief Выполнение текущих действий в очередях.
		\param elapsedSeconds Сколько секунд прошло с момента прошлого вызова Live() . Это время, на которое текущие действия (в разных очередях) могут продвинуться в выполнении.
		\param thread Идентификатор потока в котором вызывается функция.\n
		Каждый определённый поток можно игнорировать функцией Dispatcher.IgnoreThread() .\n
		По умолчанию = 0.
		Идентификаторы потоков могут быть \b только положительными.*/
		public function Live(elapsedSeconds:Number = 0.020, thread:int = 0): void
		{
			if(elapsedSeconds < 0.0)
			{
				output.Out("E: Dispatcher::Live(): elapsedTimeInSeconds = " + elapsedSeconds + " is wrong. It must be >= 0. Returning.\n", Output.ERROR);
				return;
			}
			
			//если указанный поток входит в список игнорируемых, то ничего не делаем:
			if(thread >= 0)
			{
				for(var i:int = 0; i < ignoringThreads.length; i++)
				{
					if(thread == ignoringThreads[i] || ignoringThreads[i] == -1)
					{
						return;
					}
				}
			}
			else
			{
				output.Out("W: Dispatcher::Live(): thread = " + thread + " is wrong. It must be positive.\n", Output.WARN);
			}
			
			//проход по вектору очередей:
			for (var forEachQueue:int = 0; forEachQueue < redirections.length; forEachQueue++)
			{
				//индекс текущей очереди в векторе очередей:
				var currentQueueIndex:int = redirections[forEachQueue].index;
				
				//нужно ли перейти к следующей очереди:
				var goToNextQueue:Boolean = false;
				
				//если текущая очередь одна из игнорируемых очередей, то пропускаем её:
				for(var forEachIgnoringQueues:int = 0; forEachIgnoringQueues < ignoringQueues.length; forEachIgnoringQueues++)
				{
					//если указано игнорировать все очереди:
					if(ignoringQueues[forEachIgnoringQueues] == -1)
					{
						output.Out("I: Dispatcher.Execute(): ignoring ALL queues.\n", Output.INFO);
						return;
					}
					
					//если указано игнорировать именно эту очередь:
					if(ignoringQueues[forEachIgnoringQueues] == redirections[forEachQueue].id)
					{
						output.Out("I: Dispatcher.Execute(): queue with index " + currentQueueIndex + " and id " + redirections[forEachQueue].id + " ignored.\n", Output.INFO);
						goToNextQueue = true;
						break;
					}
				}
				if(goToNextQueue == true)
				{
					continue;
				}
				
				//текущая очередь:
				var queue:Queue = queues[currentQueueIndex];
				//чтобы действие могло получить очередь, в которой оно находится, из переданного в неё Dispatcher:
				queueOfCurrentAction = queue;
				//сколько времени могут потребить действия в текущей очереди:
				var needToConsumeSecondsForCurrentQueue:Number = elapsedSeconds;
				
				//выполнение действий в очереди до тех пор, пока они не потребят всё время или не закончатся:
				for (;;)
				{
					//получение следующего действия для выполнения:
					var action:Action = queue.CurrentAction();
					//если действия закончились или их просто нет:
					if(action == null)
					{
						break;
					}
					
					//если действие выполняется впервые, то очищаем его данные, ибо с ними нельзя будет работать корректно:
					if(queue.doneCycles <= 0)
					{
						//верхним уровнем действий могут быть только действия ActionAsTask:
						(action as ActionAsTask).data.length = 0;
					}
					//выполнение действия:
					const consumedSeconds:Number = action.Execute(this, needToConsumeSecondsForCurrentQueue);
					//если действие ещё не закончилось:
					if(queue.wasActionEnded	== false)
					{
						queue.doneCycles++;
						//в Action::Execute() действие должно было вызываться до тех пор, пока оно не потребит всё время, поэтому цикл выполнен:
						break;
					}
					//действие закончилось, поэтому сбрасываем флаг для следующего действия:
					else
					{
						queue.wasActionEnded = false;
						queue.wasActionMarkedAsEnded = false;
						if(queue.remainOnCurrentAction)
						{
							queue.remainOnCurrentAction = false;
						}
						else
						{
							queue.currentAction++;
						}
						queue.doneCycles = 0;
						
						//если потреблённое время было указано неверно или действие, по счастливой случайности, потребило всё время, то переходим к следующей очереди:
						if(consumedSeconds >= needToConsumeSecondsForCurrentQueue)
						{
							break;
						}
						//пересчитываем сколько времени осталось для следующего действия:
						needToConsumeSecondsForCurrentQueue -= consumedSeconds;
					}
				}
			}
		}
		
		/** \brief Удаление очереди с указанным идентификатором.
		\details По-умолчанию будут удалены все очереди. Если указать какую-то конкретную очередь, то очередь будет очищена.\n
		Исключения удаления очередей влияют на удаление только если указано удалить все очереди (первый параметр = -1, что по-умолчанию).
		\param queueId Идентификатор очереди, которую нужно очистить. По-умолчанию будут удаляться все очереди.
		\param resetIgnoring true - игнорирование очереди будет отменено. По-умолчанию = false.
		\param exceptions Перечисленные очереди, которые НЕ нужно удалять.*/
		public function Clear(queueId:int = -1, resetIgnoring:Boolean = false, ... exceptions): void
		{
			//если по-умолчанию указано удалить все очереди:
			if(queueId == -1)
			{
				//если нужно удалить очереди с исключениями:
				const exceptionsCount:int = exceptions.length;
				if(exceptionsCount > 0)
				{
					output.Out("I: Dispatcher.Clear(): removing queues with " + exceptionsCount + " exceptions:\n", Output.INFO);
					for(var exception:int = 0; exception < exceptionsCount; exception++)
					{
						output.Out("	" + exceptions[exception] + "\n", Output.INFO);
					}
					
					//удаление всех очередей по-одной, кроме исключений:
					for(var removingQueue:int = 0; removingQueue < queues.length; removingQueue++)
					{
						//является ли текущая очередь исключением:
						var isException:Boolean = false;
						//идентификатор удаляемой очереди:
						var removingQueueId:int = QueueIdFromIndex(removingQueue);
						//если, по непонятным причинам, очереди с таким индексом нету:
						if(removingQueueId == -1)
						{
							output.Out("W: Dispatcher::Clear(): impossible happened: queue with index = " + removingQueue + " does not exist.\n", Output.WARN);
							continue;
						}
						//поиск текущей очереди в исключениях:
						for(var anotherException:int = 0; anotherException < exceptionsCount; anotherException++)
						{
							if(removingQueueId == exceptions[anotherException])
							{
								output.Out("I: Dispatcher::Clear(): queue with id " + removingQueueId + " is exception.\n", Output.INFO);
								isException	= true;
								break;
							}
						}
						//если текущая очередь в исключениях, то её удалять не нужно:
						if(isException	== true)
						{
							continue;
						}
						else
						{
							output.Out("I: Dispatcher::Clear(): queue with id " + removingQueueId + " is NOT exception.\n", Output.INFO);
						}
						
						//удаление текущей очереди:
						ClearQueue(removingQueueId, resetIgnoring);
					}
				}
				//в противном случае просто удаляем все очереди (без исключений):
				else
				{
					for(var i:int = 0; i < queues.length; i++)
					{
						//очистка массива действий внутри каждой очереди действий:
						queues[i].Clear();
						
						//удаление соответствующей очереди:
						delete queues[i];
					}
					
					//удаление всех указателей на очереди:
					queues.length = 0;
					//очистка всех перенаправлений:
					redirections.length = 0;
					
					//отменяем игнорирование всех очередей:
					ignoringQueues.length = 0;
					
					output.Out("I: Dispatcher.Clear(): all queues deleted successfully. All ignorings removed.\n", Output.INFO);
				}
				return;
			}
			
			//удаляем единственную указанную очередь:
			ClearQueue(queueId, resetIgnoring);
		}
		
		/** \brief Очистка указанной очереди.
		\param queueId Идентификатор очереди, которую нужно очистить.
		\param resetIgnoring true - игнорирование очереди будет отменено. По-умолчанию = false.*/
		public function ClearQueue(queueId:int, resetIgnoring:Boolean = false): void
		{
			if(queueId < 0)
			{
				output.Out("E: Dispatcher.DeleteQueue(): queueId = " + queueId + ". It must be positive or = -1.\n", Output.ERROR);
				return;
			}
			
			//поиск очереди с указанным идентификатором:
			var foundQueue:int = QueueIndexFromId(queueId);
			//если очереди с указанным индексом так и не было найдено:
			if(foundQueue == -1)
			{
				output.Out("W: Dispatcher.DeleteQueue(): there are NO queue with id = " + queueId + ".\n", Output.WARN);
				return;
			}
			
			//очищаем очередь с указанным индексом:
			output.Out("I: Dispatcher.DeleteQueue(): clearing queue with index = " + foundQueue + ".\n", Output.INFO);
			queues[foundQueue].Clear();
			
			//если указано, то отменяем игнорирование указанной очереди:
			//поиск указанной очереди в списке игнорируемых очередей и замена на такое число, индекса очереди которой точно не будет:
			if(resetIgnoring == true)
			{
				for(var i:int = 0; i < ignoringQueues.length; i++)
				{
					if(ignoringQueues[i] == queueId)
					{
						ignoringQueues[i] = -2;
					}
				}
			}
			
			output.Out("I: Dispatcher.DeleteQueue(): queue with id = " + queueId + " cleared.\n", Output.INFO);
		}
		
		/** \brief Игнорирование указанного потока.
		\details Если поток проигнорирован, то все вызовы функции Live() с этим потоком будут игнорироваться.\n
		Идентификаторы потоков могут быть \b только положительными.
		\param thread Поток, который нужно игнорировать. Если = -1, что по-умолчанию, то будут игнорироваться <b>все</b> потоки.*/
		public function IgnoreThread(thread:int = -1): void
		{
			//идентификатор игнорируемого потока должен быть положительным:
			if(thread < -1)
			{
				output.Out("E: Dispatcher.IgnoreThread(): thread = " + thread + ". It must be positive or = -1. Thread will NOT be added as ignored.\n", Output.ERROR);
				return;
			}

			//добавляем поток в список игнорируемых потоков:
			ignoringThreads.push(thread);
		}
		
		/** \brief Сброс игнорирования потока.
		\param thread Идентификатор потока, игнорирование которого нужно отменить.\n
		Если == -1, что по-умолчанию, то будут отменены игнорирования всех потоков.*/
		public function ResetThreadIgnoring(thread:int = -1): void
		{
			//если указано -1, то отменяем игнорирование всех очередей:
			if(thread == -1)
			{
				ignoringThreads.length = 0;
				return;
			}
			
			//поиск указанного потока в потоках, которые уже игнорируются:
			for(var i:int = 0; i < ignoringThreads.length; i++)
			{
				if(ignoringThreads[i] == thread)
				{
					output.Out("I: Dispatcher.ResetThreadIgnoring(): thread " + thread + " found. Changing it to -2.\n", Output.INFO);
					ignoringThreads[i] = -2;
				}
			}
		}
		
		/** \brief Игнорируется ли указанный поток.
		\param thread Номер потока, игнорирование которого нужно узнать.
		\return true - указанный поток игнорируется.*/
		public function IsThreadIgnoring(thread:int): Boolean
		{
			if(thread < 0)
			{
				output.Out("I: Dispatcher.IsThreadIgnoring(): thread = " + thread + ". It must be positive.\n", Output.INFO);
				return false;
			}
			
			//поиск указанного потока в потоках, которые уже игнорируются:
			for(var i:int = 0; i < ignoringThreads.length; i++)
			{
				if(ignoringThreads[i] == thread)
				{
					output.Out("I: Dispatcher.IsThreadIgnoring(): ignoring thread " + thread + " found.\n", Output.INFO);
					return true;
				}
			}
			
			return false;
		}
		
		/** \brief Игнорирование указанной очереди.
		\details Состояние действий в очереди останется прежним, но они перестанут выполняться.\n
		После отмены игнорирования выполнения продолжиться с остановленного места.
		\param queueId Идентификатор очереди, которая должна игнорироваться. Если == -1, то будут игнорироваться все очереди.*/
		public function IgnoreQueue(queueId:int): void
		{
			//проверку номера очереди на правильность совершать не нужно, из-за использования индексов очередей (например можно сначала указать игнорирование очереди с указанным индексом, а только потом создать очередь с таким индексом):
			if(queueId < -1)
			{
				output.Out("E: Dispatcher.IgnoreQueue(): queueId = " + queueId + ". It must be positive.\n", Output.ERROR);
				return;
			}
			
			ignoringQueues.push(queueId);
		}
		
		/** \brief Сброс игнорирования очереди.
		\param queueId Идентификатор очереди, игнорирование которой нужно отменить.\n
		Если == -1, что по умолчанию, то будут отменены игнорирования всех очередей.\n
		Выполнение действий очереди с указанным идентификатором продолжиться с остановленного места.*/
		public function ResetQueueIgnoring(queueId:int): void
		{
			//если указано отменить игнорирование всех очередей:
			if(queueId == -1)
			{
				ignoringQueues.length = 0;
				return;
			}
			
			if(queueId < -1)
			{
				output.Out("E: Dispatcher.ResetQueueIgnoring(): queueId = " + queueId + ". It must be positive.\n", Output.ERROR);
				return;
			}
			
			//поиск указанной очереди в списке игнорируемых очередей и замена на такое число, индекса очереди которой точно не будет:
			for(var i:int = 0; i < ignoringQueues.length; i++)
			{
				if(ignoringQueues[i] == queueId)
				{
					output.Out("I: Dispatcher.ResetQueueIgnoring(): ignoring queue " + queueId + " found.\n", Output.INFO);
					ignoringQueues[i] = -2;
				}
			}
		}
		
		/** \brief Игнорируется ли указанная очередь.*/
		public function IsQueueIgnoring(queueId:int): Boolean
		{
			for(var i:int = 0; i < ignoringQueues.length; i++)
			{
				if(ignoringQueues[i] == queueId) return true;
			}
			return false;
		}
		
		/** \brief Создание и добавление нового действия в указанную очередь.
		\param queueId Идентификатор очереди, в которую нужно добавить очередь. Идентификатор может быть любым числом >= 0. Если -1, то будет создана очередь с первым найденным свободным идентификатором и действие будет добавлено в неё. Действия будут выполняться в порядке возрастания идентификаторов.
		\param actionDesc Описание добавляемого действия.
		\return Идентификатор очереди, в которую было добавлено действие.*/
		public function CreateAction(queueId:int, actionDesc:ActionDesc): ActionCreationResult
		{
			var actionCreationResult:ActionCreationResult = new ActionCreationResult(-1, -1);
			
			if(queueId < -1)
			{
				output.Out("E: Dispatcher.CreateAction(): queueId = " + queueId + ". It must be positive.\n", Output.ERROR);
				return actionCreationResult;
			}
			
			queueId	= AddAction(queueId, actionDesc);
			
			//возвращаем индекс очереди, в которую было добавлено текущее действие и индекс действия в этой очереди:
			actionCreationResult.queueId = queueId;
			const queueIndex:int = QueueIndexFromId(queueId);
			var queue:Queue = queues[queueIndex];
			actionCreationResult.actionIndex = queue.ActionsCount() - 1;
			
			return actionCreationResult;
		}
		
		/** \brief Переход на указанное действие в указанной очереди.
		\param queueId Идентификатор очереди, внутри которой нужно совершить переход.
		\param actionIndex Индекс действия, на которое нужно совершить переход.*/
		public function GoToAction(queueId:int, actionIndex:int): void
		{
			var queue:Queue = GetQueue(queueId);
			if(queue == null)
			{
				output.Out("E: Dispatcher.GoToAction(): there are no queue with id = " + queueId + ".\n", Output.ERROR);
				return;
			}
			
			queue.GoToAction(actionIndex);
		}
		
		/** \brief Какое количество действий находится внутри указанной очереди.
		\param queueId Идентификатор очереди, количество действий внутри которой необходимо определить.
		\return Количество действий в указанной очереди. Возвращает ноль если очереди с таким идентификатором не существует.*/
		public function ActionsCount(queueId:int): int
		{
			var queue:Queue = GetQueue(queueId);
			if(queue == null)
			{
				output.Out("E: Dispatcher.ActionsCount(): there are no queue with id = " + queueId + ".\n", Output.ERROR);
				return 0;
			}
			return queue.ActionsCount();
		}
		
		/** \brief Закончились ли действия в указанных очередях. Если ни одна очередь не указана, то будет проверяться во всех очередях.
		\details
		\code
		//закончились ли действия в очередях с идентификаторами 14 и 126:
		dispatcher.IsActionsEnded(14, 126);
		\endcode
		\param queues Перечисление очередей, завершение действий в которых нужно проверять.*/
		public function IsActionsEnded(... queues): Boolean
		{
			//закончились ли действия:
			var isActionsEnded:Boolean = true;
			
			//если нужно проверять в конкретных очередях:
			if(queues.length > 0)
			{
				for each(var queueId:int in queues)
				{
					var queue:Queue = GetQueue(queueId);
					//если очередь с таким идентификатором вообще существует:
					if(queue != null)
					{
						if(queue.CurrentAction() != null)
						{
							isActionsEnded = false;
							break;
						}
					}
					else
					{
						output.Out("W: Dispatcher.IsActionsEnded(): queue with id = " + queueId + " does NOT exist.\n", Output.WARN);
					}
				}
			}
			//если нужно проверять все очереди:
			else
			{
				for(var queueIndex:int = 0; queueIndex < this.queues.length; queueIndex++)
				{
					if(this.queues[queueIndex].CurrentAction() != null)
					{
						isActionsEnded = false;
						break;
					}
				}
			}
			
			return isActionsEnded;
		}
		
		
		
		/** \brief Получение очереди с указанным идентификатором.
		\param id  Идентификатор очереди, которую нужно получить.\n
		Полученная очередь может удалить в другом потоке, поэтому нужно быть осторожным при её использовании.
		\return Очередь, имеющий идентификатор. Если очереди с таким идентификатором нет, то будет возвращен null.*/
		public function GetQueue(id:int): Queue
		{
			const index:int = QueueIndexFromId(id);
			
			//если очереди с указанным id не существует:
			if(index == -1) return null;
			return queues[index];
		}
		
		/** \brief Получение позиции очереди в векторе по идентификатору.
		\param id Идентификатор, по которому нужно получить номер очереди.
		\param silent Если функция вызывается для проверки, то писать отладочную информацию НЕ нужно.
		\return Индекс очереди, идентификатор которой указан.*/
		private function QueueIndexFromId(id:int, silent:Boolean = false): int
		{
			if (silent == false) output.Out("I: Dispatcher.QueueIndexFromId()\n", Output.INFO);
			var foundIndex:int = -1;
			for(var i:int = 0; i < redirections.length; i++)
			{
				if(redirections[i].id == id)
				{
					foundIndex = redirections[i].index;
					break;
				}
			}
			if(foundIndex == -1)
			{
				if(silent == false) output.Out("I: Dispatcher.QueueIndexFromId(): there are NO queue with id = " + id + ". Not so bad - it can be just looking for queue with such id in case of first deal adding.\n", Output.INFO);
			}
			else output.Out("I: Dispatcher.QueueIndexFromId(): queue with id = " + id + " found. It has index = " + foundIndex + ".\n", Output.INFO);
			
			return foundIndex;
		}
		
		/** \brief Получение идентификатора очереди по позиции в векторе (индексу).
		\param index Позиция очереди в векторе.
		\return Идентификатор очереди. -1, если очередь с таким индексом отсутствует.*/
		private function QueueIdFromIndex(index:int): int
		{
			if(index < 0 || index >= queues.length)
			{
				output.Out("I: Dispatcher.QueueIdFromIndex(): index = " + index + " is wrong. Returning -1.\n", Output.INFO);
				return -1;
			}
			
			for(var i:int = 0; i < redirections.length; i++)
			{
				if(redirections[i].index == index) return redirections[i].id;
			}
			return -1;
		}
		
		/** \brief Добавление новой очереди.
		\details Если id указан неверно, то очередь добавлена не будет, поэтому, чтобы не было утечек памяти, queue нужно удалить извне (везёт если в языке программирования не бывает утечек памяти).
		\param id Идентификатор добавляемой очереди.
		\param queue Указатель на очередь, которую нужно добавить.
		\return Идентификатор добавленной очереди - отличается от id только если id == -1. -1 - очередь НЕ была добавлена: неверный id .*/
		private function AppendRedirection(id:int, queue:Queue): int
		{
			//если было указано добавить очередь с любым свободным идентификатором:
			if(id == -1)
			{
				id = GetFreeId();
				output.Out("I: Dispatcher.AppendRedirection(): id was equal -1. So found free id = " + id + ".\n", Output.INFO);
			}
			
			//удостовериться, что очереди с указанным идентификатором ещё не существует:
			var existingIndex:int = QueueIndexFromId(id, true);
			//если очередь с таким идентификатором уже существует:
			if(existingIndex != -1)
			{
				output.Out("E: Dispatcher.AppendRedirection(): queue with id = " + id + " already exists.\n", Output.ERROR);
				return -1;
			}
			
			output.Out("I: Dispatcher.AppendRedirection(): queue with id = " + id + " has index = " + existingIndex + ".\n", Output.INFO);
			
			//добавление нового перенаправления:
			var idToIndex:IdToIndex = new IdToIndex(id, redirections.length);
			output.Out("I: Dispatcher.AppendRedirection(): created new IdToIndex =\n		idToIndex.id = " + idToIndex.id + ";\n		idToIndex.index = " + idToIndex.index + ";\n", Output.INFO);
			redirections.push(idToIndex);
			//добавление очереди:
			queues.push(queue);
			//новая сортировка идентификаторов по возрастанию:
			ResortRedirections();
			
			//возвращаем идентификатор только что добавленной очереди:
			return id;
		}
		
		/** \brief Сортировка перенаправлений по возрастанию идентификаторов.*/
		private function ResortRedirections(): void
		{
			if(redirections.length == 0)
			{
				output.Out("I: Dispatcher.ResortRedirection(): there are NO redirection elements.\n", Output.INFO);
				return;
			}
			
			output.Out("I: Dispatcher.ResortRedirection(): array before resorting:\n", Output.INFO);
			for(var printingBefore:int = 0; printingBefore < redirections.length; printingBefore++)
			{
				output.Out("	| " + redirections[printingBefore].id + " | " + redirections[printingBefore].index + " |\n", Output.INFO);
			}
			
			//каждое перенаправление (IdToIndex) будет копироваться из redirections в resorted, начиная с наименьших id:
			var resorted:Array = [];
			
			var minId:int = -1;
			var indexOfMinId:int = 0;
			//копирование каждого перенаправления:
			for(var i:int = 0; i < redirections.length; i++)
			{
				//поиск минимального перенаправления:
				for(var i2:int = 0; i2 < redirections.length; i2++)
				{
					//если id == -1, то он уже скопирован:
					if(redirections[i2].id == -1) continue;
					
					//если minId == -1, то ещё ни один минимальный id не был найден:
					if(minId == -1)
					{
						minId = redirections[i2].id;
						indexOfMinId = i2;
						continue;
					}
					else
					{
						if(redirections[i2].id < minId)
						{
							minId = redirections[i2].id;
							indexOfMinId = i2;
							continue;
						}
						else if(redirections[i2].id == minId)
						{
							output.Out("E: Dispatcher.ResortRedirection(): found redirections with similiar id:\n	redirections[" + indexOfMinId + "].id = " + redirections[indexOfMinId].id + ";\n	redirections[" + indexOfMinId + "].index = " + redirections[indexOfMinId].index + ";\n	redirections[" + i2 + "].id = " + redirections[i2].id + ";\n	redirections[" + i2 + "].index = " + redirections[i2].index + ";\n", Output.ERROR);
						}
					}
				}
				
				//копирование перенаправления с минимально найденным индексом:
				var copying:IdToIndex = redirections[indexOfMinId];
				var dest:IdToIndex = new IdToIndex(copying.id, copying.index);
				resorted[i] = dest;
				//указываем, что это перенаправление уже скопировано:
				redirections[indexOfMinId].id = -1;
				
				minId = -1;
				indexOfMinId = 0;
			}
			
			redirections = resorted;
			
			output.Out("I: Dispatcher.ResortRedirection(): array AFTER resorting:\n", Output.INFO);
			for(var printingAfter:int = 0; printingAfter < redirections.length; printingAfter++)
			{
				output.Out("	| " + redirections[printingAfter].id + " | " + redirections[printingAfter].index + " |\n", Output.INFO);
			}
		}
		
		/** \brief Получение свободного идентификатора.*/
		private function GetFreeId(): int
		{
			//ещё не занятый идентификатор:
			var freeId:int = 0;
			//найдена ли очередь с таким идентификатором (есть ли пересечение):
			var suchIdExists:Boolean = false;
			//поиск свободного идентификатора:
			for(var i:int = 0; i < redirections.length; i++)
			{
				for(var i2:int = 0; i2 < redirections.length; i2++)
				{
					if(freeId == redirections[i2].id)
					{
						suchIdExists = true;
						break;
					}
				}
				
				if(suchIdExists == true)
				{
					freeId++;
					suchIdExists = false;
					continue;
				}
				else break;
			}
			
			output.Out("I: Dispatcher.GetFreeId(): free id = " + freeId + " found.\n", Output.INFO);
			return freeId;
		}
		
		/** \brief Добавление нового действия в указанную очередь.
		\details Указанное действие добавляется в конец очереди.\n
		Если номер очереди == -1, то к списку очередей будет добавлена новая очередь и действие добавится в неё.
		\param queueId Идентификатор очереди, в конец которой будет добавлено действие.
		\param action Первый элемент - номер действия. Остальные - параметры.
		\return Идентификатор очереди, в которую было добавлено действие.*/
		private function AddAction(queueId:int, actionDesc:ActionDesc): int
		{
			if(queueId < -1)
			{
				output.Out("E: Dispatcher.AddAction(): queueId = " + queueId + ". It must be positive.\n", Output.ERROR);
				return -1;
			}
			
			var action:Action = actionDesc.CreateAction();
			
			//queueIndex будет = -1 либо если queueId указано -1 (изначально), либо если такой очереди ещё не существует:
			var queueIndex:int = QueueIndexFromId(queueId);
			//создаём и добавляем новую очередь:
			if(queueIndex == -1)
			{
				output.Out("I: Dispatcher.AddAction(): there are NO queue with id = " + queueId + ". Will be created new queue.\n", Output.INFO);
				var queue:Queue = new Queue(output);
				output.Out("I: Dispatcher.AddAction(): queue created.\n", Output.INFO);
				queue.AddAction(action);
				output.Out("I: Dispatcher.AddAction(): appending redirection.\n", Output.INFO);
				queueId = AppendRedirection(queueId, queue);
				if(queueId == -1)
				{
					output.Out("E: Dispatcher.AddAction(): queue was NOT appended. Trying id = " + queueId + ".\n", Output.ERROR);
					//в этом языке не нужно удалять очередь после её неудачного добавления...
				}
			}
			//в противном случае добавляем действие в уже существующую очередь:
			else
			{
				queues[queueIndex].AddAction(action);
			}
			
			//возвращаем индекс очереди, в которую было добавлено текущее действие:
			return queueId;
		}
		
		/** Проверяет наличие указанного количества аргументов в действии.
		\return true если какая-либо ошибка.*/
		public static function CheckArguments(context:String, param:Param, count:int): Boolean
		{
			if (count > param.argumentsAsActions.length)
			{
				param.action.output.Out("E: CheckArguments(): " + context + ": requested " + count + " arguments but there are just " + param.argumentsAsActions.length + ".", Output.ERROR);
				param.queue.ActionEnded();
				return true;
			}
			
			return false;
		}
		
		/** Устанавливает данные действия в нулевое значение.*/
		public static function InitData(param:Param, count:int): void
		{
			for (var i:int = 0; i < count; i++)
			{
				param.action.data[i] = new AbstractData;
			}
		}
		
		/** Проверяем что указанный параметр указанного типа.
		\return true если произошла какая-либо ошибка.*/
		public static function CastTo(context:String, param:Param, which:int, type:Class): Boolean
		{
			var some:* = param.argumentsAsActions[which].GetData().GetData();
			if ((some is type) == false)
			{
				param.action.output.Out("E: CastTo(): " + context + ": " + some + " is NOT of type " + type + ".", Output.ERROR);
				param.queue.ActionEnded();
				return true;
			}
			return false;
		}
		
	}

}


