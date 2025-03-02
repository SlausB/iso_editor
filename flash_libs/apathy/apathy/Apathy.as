/// @cond
package apathy 
{
	import com.adobe.serialization.json.JSON;
	import com.junkbyte.console.Cc;
	import de.polygonal.ds.DLL;
	import de.polygonal.ds.DLLNode;
	import de.polygonal.ds.Itr;
	import design.Bound;
	import design.Info;
	import design.infos.EntityInfo;
	import flash.utils.Dictionary;
	import server.ServerAction;
	
	/// @endcond
	
	/** Экземпляр взаимодействия с сервером по принципу "храни то, не зная что" когда имеется возможность лишь воспроизвести тип объекта, но данные этого объекта хранятся абстрагированно от сервера и этой методики распознавания типа.*/
	public class Apathy 
	{
		/** Освободившиеся идентификаторы объектов.*/
		public var _freeInstanceIds : Vector.< int > = new Vector.< int >;
		
		/** Следующий свободный идентификатор, который можно присвоить какому-либо новому объекту.*/
		public var _nextFreeInstanceId : int = 1;
		
		private var _myAliases : Vector.< MyAlias >;
		private var _creator : Function;
		private var _bounds : Vector.< Bound >;
		
		
		private var _creationHandler : Function;
		private var _postLoad : Function;
		
		/** Занятые идентификаторы объектов - необходимо для формирования списка свободных идентификаторов при загрузке и для отладки присвоения уникальных идентификаторов.*/
		public var _occupiedInstanceIds : Vector.< int > = new Vector.< int >;
		
		
		/** Конструктор.
		\param myAliases Описания объектов собственного типа..
		\param creator function( info : Info ) : Serializable Функция создания объектов дизайнерского типа.
		\param creationHandler function( object : Serializable ) : void Вызывается при создании какого-либо объекта - могут быть совершены какие-либо действия, например, для его инициализации.
		\param postLoad function( object : Serializable ) : void Called right after object.Load() call.
		.*/
		public function Apathy( myAliases : Vector.< MyAlias >, creator : Function, bounds : Vector.< Bound >, creationHandler : Function, postLoad : Function )
		{
			_myAliases = myAliases;
			_creator = creator;
			_bounds = bounds;
			_creationHandler = creationHandler;
			_postLoad = postLoad;
		}
		
		
		/** Вызывает acceptor для всех объектов класса Serializable в указанном списке.
		\param acceptor function( serializable : Serializable ) : Boolean - должна возвращать true если необходимо продолжать итерацию.*/
		public static function ForEach( where : DLL, acceptor : Function ) : void
		{
			var iterator : Itr = where.iterator();
			while ( iterator.hasNext() )
			{
				var data : Serializable = iterator.next() as Serializable;
				if ( data != null )
				{
					if ( acceptor( data ) == false )
					{
						break;
					}
				}
				else
				{
					iterator.remove();
				}
			}
		}
		
		/** Создать объект указанного пользовательского типа. Для создания объектов дизайнерского типа см. CreateObjectByInfo()
		\param myAliasIndex Индекс TabAlias'а из переданного в конструкторе массива.
		\param type Тип объекта, указанный в myAliases
		\param preCallback function(object:Serializable, opaqueData:*): void - вызывается с созданным объектом ДО того как будут вызваны его OnLoad() и OnBirth() . Null если preCallback не нужен.
		\param postCallback то же что и preCallback, то вызывается ПОСЛЕ вызова функций OnLoad() и OnBirth()
		\param opaqueData Будет передано в callback.
		\return Созданный объект или null в случае какой-либо ошибки.
		*/
		public function CreateObjectByMyAlias( myAliasIndex : int, preCallback : Function = null, postCallback : Function = null, opaqueData : * = null, birth : Boolean = true ) : Serializable
		{
			var found : MyAlias = null;
			for each ( var myAlias : MyAlias in _myAliases )
			{
				if ( myAlias._id == myAliasIndex )
				{
					found = myAlias;
					break;
				}
			}
			
			if ( found == null )
			{
				Cc.error( "E: Apathy.CreateObjectByMyAlias(): custom alias by index \"" + myAliasIndex + "\" does NOT exist." );
				return null;
			}
			return CreateObject( new ( found._itemClass as Class ), preCallback, postCallback, opaqueData, 0, found._id, birth );
		}
		
		/** То же что и CreateObjectByMyAlias() только для объектов дизайнерского типа.
		\sa CreateObjectByMyAlias() */
		public function CreateObjectByInfo( info : Info, preCallback : Function = null, postCallback : Function = null, opaqueData : * = null, birth : Boolean = true ) : Serializable
		{
			var typeId : int = -1;
			if ( info is EntityInfo )
			{
				typeId = ( info as EntityInfo ).id;
			}
			return CreateObject( _creator( info ), preCallback, postCallback, opaqueData, info.__tabBound.hash, typeId, birth );
		}
		
		private function CreateObject( object : Serializable, preCallback : Function, postCallback : Function, opaqueData : *, typeName : uint, typeId : int, birth : Boolean ) : Serializable
		{
			if ( object == null )
			{
				Cc.error( "E: Apathy.CreateObject(): object is null." );
				return null;
			}
			
			object._typeName = typeName;
			
			if ( typeId >= 0 )
			{
				object._typeId = typeId;
			}
			
			if ( _freeInstanceIds.length > 0 )
			{
				object.SetInstanceId( _freeInstanceIds.shift() );
			}
			else
			{
				object.SetInstanceId( _nextFreeInstanceId );
				++_nextFreeInstanceId;
			}
			
			_occupiedInstanceIds.push( object.instanceId );
			
			_creationHandler( object );
			
			if ( preCallback != null )
			{
				preCallback( object, opaqueData );
			}
			
			object.OnLoad( Origin.GAME );
			
			_postLoad( object );
			
			if ( birth )
			{
				object.OnBirth( Origin.GAME );
			}
			
			//чтобы объект, хотя бы, точно появился на сервере:
			object.ChangeOnServer();
			
			if ( postCallback != null )
			{
				postCallback( object, opaqueData );
			}
			
			return object;
		}
		
		/** Записать идентификацию info в объект, чтобы потом можно было прочитать посредством ReadInfo() из объекта, получив info.*/
		public function WriteInfo( info : Info ) : Object
		{
			var object : Object = new Object;
			object[ Serializable.SRV_TYPE ] = info.__tabBound.hash;
			if ( info is EntityInfo )
			{
				object[ Serializable.SRV_ID ] = ( info as EntityInfo ).id;
			}
			else
			{
				object[ Serializable.SRV_ID ] = -1;
			}
			return object;
		}
		
		/** Читает info из указанного объекта, записанного туда посредством WriteInfo().*/
		public function ReadInfo( source : Object ): Info
		{
			if ( source == null )
			{
				return null;
			}
			return FindInfoByAliasAndId( source[ Serializable.SRV_TYPE ], source[ Serializable.SRV_ID ] );
		}
		
		/** Returns true if specified info and saved (serialized) are equal.*/
		public function IsEqual( one : Info, another : Object ): Boolean
		{
			if ( one.__tabBound.hash != another[ Serializable.SRV_TYPE ] )
			{
				return false;
			}
			if ( one is EntityInfo )
			{
				return ( one as EntityInfo ).id == another[ Serializable.SRV_ID ];
			}
			return true;
		}
		
		/** Возвращает объект по его игровому идентификатору или null если такого объекта нет.
		\param objectClass Класс искомого объекта.*/
		public static function FindObjectByInstanceId( where : DLL, instanceId : int, objectClass : Class) : Serializable
		{
			var found : Serializable = null;
			ForEach( where, function( serializable : Serializable ) : Boolean
			{
				if ( serializable.instanceId == instanceId )
				{
					if ( serializable is objectClass )
					{
						found = serializable;
					}
					return false;
				}
				return true;
			} );
			return found;
		}
		
		/** Поиск объекта по укороченному имени вкладки и его идентификатора внутри этой вкладки.*/
		public function FindInfoByAliasAndId( hash : uint, id : int ) : Info
		{
			for each ( var bound : Bound in _bounds )
			{
				if ( bound.hash == hash )
				{
					for each ( var some : Object in bound.objects )
					{
						if ( "id" in some )
						{
							if ( some.id == id )
							{
								return some as Info;
							}
						}
						else
						{
							Cc.error( "E: Postprocessed.FindInfoByAliasAndId(): table with hash \"" + hash.toString() + "\" was found but objects within it do NOT have \"id\" field. Returning null." );
							return null;
						}
					}
					
					Cc.error( "E: Postprocessed.FindInfoByAliasAndId(): object with id " + id + " was NOT found within table \"" + hash.toString() + "\". Returning null." );
					return null;
				}
			}
			
			Cc.error( "E: Postprocessed.FindInfoByAliasAndId(): table with hash \"" + hash + "\" was NOT found. Returning null." );
			return null;
		}
		
		/** Удалить объект. Для сохранения возможности продолжения итерирования по спискам, в которых находится текущий объект, он должен удаляться из них только по завершении итерации, поэтому объект останется в списках, однако будет иметь флаг condemned = true.*/
		public function Remove( serializable : Serializable): void
		{
			if ( serializable._removed )
			{
				Cc.stack( "E: Apathy.Remove(): object \"" + serializable + "\" was already removed. It's description: \"" + serializable.Wrap() + "\". Fix it as soon as possible! Callstack:" );
				return;
			}
			
			serializable._removed = true;
			
			_freeInstanceIds.push( serializable.instanceId );
			
			if ( serializable._embryo )
			{
				Global.game._server.LogError( "E: Apathy.Remove(): removing objects \"" + serializable.Wrap() + "\" which was NOT even created on server." );
			}
			else
			{
				Global.game._server.PushAction( ServerAction.TYPE_REMOVE, serializable );
			}
			
			serializable.Destroy();
		}
		
		/** Increments specified integral value or applies to 1 if it was absent.*/
		public static function Increment( data : Object, field : String ) : void
		{
			if ( field in data && data[ field ] is int )
			{
				data[ field ] += 1;
			}
			else
			{
				data[ field ] = 1;
			}
		}
		
		/** Returns specified integer value or 0 if it wasn't specified or isn't integer.*/
		public static function ReadInt( data : Object, field : String ) : int
		{
			if ( field in data && data[ field ] is int )
			{
				return data[ field ] as int;
			}
			return 0;
		}
	}

}

