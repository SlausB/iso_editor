/// @cond
package actions 
{
	
	/// @endcond
	
	/** \brief В очередь с каким идентификатором было добавлено действие функцией Dispatcher.CreateAction() и под каким индексом оно находится в этой очереди.*/
	public class ActionCreationResult 
	{
		/** \brief Обязательный конструктор.
		\param queueId В очередь с каким идентификатором было добавлено действие.
		\param actionIndex Под каким индексом находится добавленное действие в очереди.*/
		public function ActionCreationResult(queueId:int, actionIndex:int) 
		{
			this.queueId = queueId;
			this.actionIndex = actionIndex;
		}
		
		/** \brief В очередь с каким идентификатором было добавлено действие.*/
		public var queueId:int;
		
		/** \brief Под каким индексом находится добавленное действие в очереди.*/
		public var actionIndex:int;
	}

}