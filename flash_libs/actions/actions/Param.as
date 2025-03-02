/// @cond
package actions 
{
	
	/// @endcond
	
	/** Передаётся в действие при его выполнении.*/
	public class Param 
	{
		/** Диспетчер, в котором выполняется действие.*/
		public var dispatcher:Dispatcher;
		/** В какой очереди выполняется действие.*/
		public var queue:Queue;
		/** В рамках чего выполняется действие. Здесь можно хранить промежуточные данные действия.*/
		public var action:ActionAsTask;
		/** \brief С какими параметрами вызывать задание.*/
		public var argumentsAsActions:Vector.<Action>;
		
		
		public function Param(dispatcher:Dispatcher, queue:Queue, action:ActionAsTask, argumentsAsActions:Vector.<Action>) 
		{
			this.dispatcher = dispatcher;
			this.queue = queue;
			this.action = action;
			this.argumentsAsActions = argumentsAsActions;
		}
		
	}

}