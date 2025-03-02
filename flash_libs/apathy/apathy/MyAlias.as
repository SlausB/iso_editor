/// @cond
package apathy
{
	
	/// @endcond
	
	/** Объект собственного типа, не указанный в XLS.*/
	public class MyAlias 
	{
		public var _itemClass : Class;
		public var _id : int;
		
		/** Конструктор.
		\param itemClass Logic storage.
		\param id Must differ from any other "my alias" ids.*/
		public function MyAlias( itemClass : Class, id : int )
		{
			_itemClass = itemClass;
			_id = id;
		}
		
	}

}

