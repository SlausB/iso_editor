/// @cond
package actions 
{
	
	/// @endcond
	
	/** \brief Перенаправление идентификатора очереди на индекс в массиве очередей.
	\details Используется внутри Dispatcher'а для нужд реализации.*/
	public class IdToIndex 
	{
		/** \brief Конструктор.*/
		public function IdToIndex(id:int = -1, index:int = -1) 
		{
			this.id = id;
			this.index = index;
		}
		
		/** \brief Идентификатор очереди.
		\details От нуля и выше.*/
		public var id:int;
		
		/** \brief Индекс очереди в массиве очередей.*/
		public var index:int;
		
	}

}