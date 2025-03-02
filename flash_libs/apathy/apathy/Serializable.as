/// @cond
package apathy 
{
	import com.adobe.serialization.json.JSON;
	import com.junkbyte.console.Cc;
	import de.polygonal.ds.DLL;
	import de.polygonal.ds.DLLNode;
	import design.Info;
	import design.infos.EntityInfo;
	import server.ServerAction;
	
	/// @endcond
	
	/** Объект, который может быть сохранён на сервере и загружен из него в массив объектов.*/
	public class Serializable
	{
		/** Хранение текущего объекта в списке. Null если объект вообще не хранится в списке.*/
		public var _hooks : Vector.< DLLNode > = null;
		
		/** Текущие данные объекта. Могут быть сериализованы (сохранены) на сервере вызовом ChangeOnServer() .*/
		public var _data : Object = new Object;
		
		/** Кеш имени типа объекта. Синоним понятию "tabAlias".*/
		public var _typeName : uint = 0;
		/** Идентификатор внутри типа. Например "10-ый домик среди объектов типа "домик"". Может не использоваться (и, таким образом, оставаться равным -1).*/
		public var _typeId : int = -1;
		
		/** Идентификатор экземпляра объекта. Отличается от идентификаторов всех других объектов в игре на данный момент. Является, по совместительству, ключём объекта при общении с сервером.*/
		public var _instanceId : int = -1;
		
		/** Класс объекта (имя вкладки в XLS или жёстко прописанный идентификатор) - так называемый "tab alias".*/
		public static const SRV_TYPE : String = "t";
		/** Идентификатор объекта внутри своего класса.*/
		public static const SRV_ID : String = "i";
		/** Сквозной идентификатор конкретного экземпляра объекта на сервере. Используется в том числе и на сервере как ключ для хранения (изменения и удаления) объектов.*/
		public static const SRV_INSTANCE_ID : String = "s";
		/** Данные, специфичные для каждого конкретного объекта.*/
		public static const SRV_DATA : String = "d";
		
		/** Устанавливается в true при удалении с сервера для предотвращения повтороного удаления (из-за чего могут удалиться другие объекты).*/
		public var _removed : Boolean = false;
		
		/** true если объект ещё ни разу не был сохранён (создан) на сервере.*/
		public var _embryo : Boolean = true;
		
		
		/** Добавить объект в указанный массив.*/
		final public function AddTo( holder : DLL ) : void
		{
			if ( _hooks == null )
			{
				_hooks = new Vector.< DLLNode >;
			}
			
			_hooks.push( holder.append( this ) );
		}
		
		/** Вызывается при загрузке от сервера. Данные объекта находятся в data. Могут произведены действия для десереализации данных, однако обращений к другим объектам не должно быть, так как они ещё могут быть не загружены. После этой функции вызывается OnBirth()
		\param origin Константа из класса Origin
		*/
		public function OnLoad( origin : int ) : void
		{
		}
		
		/** Вызывается после OnLoad(), когда уже все объекты загружены. Могут происходить обращения к другим объектам.
		\param origin Константа из класса Origin. Та же что и была передана в OnLoad().*/
		public function OnBirth( origin : int ) : void
		{
		}
		
		public function ChangeOnServer() : void
		{
			if ( _removed )
			{
				Cc.error("E: Serializable.ChangeOnServer(): changing objects which was removed previously.");
				return;
			}
			
			Global.game._server.PushAction( ServerAction.TYPE_CHANGE, this );
		}
		
		/** Подготовить данные, пригодные для сериализации на сервере. Переопределять функцию НЕ нужно! */
		final public function Wrap() : String
		{
			var object : Object = new Object;
			object[ Serializable.SRV_TYPE ] = _typeName;
			if ( _typeId >= 0 )
			{
				object[ Serializable.SRV_ID ] = _typeId;
			}
			else
			{
				delete object[ Serializable.SRV_ID ];
			}
			object[ Serializable.SRV_INSTANCE_ID ] = _instanceId;
			object[ Serializable.SRV_DATA ] = _data;
			return com.adobe.serialization.json.JSON.encode( object );
		}
		
		/** Здесь можно выполнять различные действия по удалению объекта для облегчения участи garbage collector'а.*/
		public function Destroy() : void
		{
			if ( _hooks != null )
			{
				for each ( var listNode : DLLNode in _hooks )
				{
					listNode.unlink();
				}
				_hooks.length = 0;
				_hooks = null;
			}
			
			_data = null;
		}
		
		public function get instanceId() : int
		{
			return _instanceId;
		}
		
		public function SetInstanceId( instanceId : int ) : void
		{
			_instanceId = instanceId;
		}
		
		/** Must return true to let Update() be called from time to time.*/
		public function ShouldBeUpdated() : Boolean
		{
			return false;
		}
		
		/** Called when all objects was loaded so that OnLoad() and OnBirth() for all of them was already called. Use this function to start some composite actions or something like that.*/
		public function GearUp() : void
		{
		}
		
		/** Make object pointing at other info leaving it's data and instance id the same. Consequences of this lie on this function user's shoulders (no OnLoad() nor OnBirth() will be called, so user will must redisplay object and something like that).
		\param myAliasOrInfo Object of MyAlias or Info classes.
		*/
		public function Rebind( myAliasOrInfo : * ) : void
		{
			if ( myAliasOrInfo is MyAlias )
			{
				var myAlias : MyAlias = myAliasOrInfo as MyAlias;
				_typeName = 0;
				_typeId = myAlias._id;
			}
			else if ( myAliasOrInfo is Info )
			{
				var info : Info = myAliasOrInfo as Info;
				_typeName = info.__tabBound.hash;
				_typeId = info is EntityInfo ? ( info as EntityInfo ).id : 0;
			}
			else
			{
				Cc.error( "E: Serializable.Rebind(): pass something better." );
				return;
			}
			
			ChangeOnServer();
		}
		
	}

}

