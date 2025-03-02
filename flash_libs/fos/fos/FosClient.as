package fos
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.setTimeout;
	
	/** Событие для вывода сообщений. Для получения отладочных сообщений от клиента следует подвязаться на это событие. test*/
	[Event(name = "fosTrace", type = "fos.FosTraceEvent")]
	/** Подключение к серверу.*/
	[Event(name = "fosConnection", type = "fos.FosConnectionEvent")]
	/** Получение целостного сообщения от сервера. Содержит в себе бинарные данные сообщения.*/
	[Event(name = "fosMessage", type = "fos.FosMessageEvent")]
	/** Отключение от сервера. Выбрасывается только когда сервер разрывает соединения (или само-собой). НЕ выбрасывается если разорвать соединение по собственной инициативе посредством FosClient.Disconnect().*/
	[Event(name = "fosDisconnection", type = "fos.FosDisconnectionEvent")]
	[Event(name = "fosIOError", type = "fos.FosIOErrorEvent")]
	[Event(name = "fosSecurityError", type = "fos.FosSecurityErrorEvent")]
	public class FosClient extends EventDispatcher implements FosDataHandler
	{
		private var _socket : Socket = new Socket;
		
		private var _host : String;
		private var _port : int;
		
		/** Уже полученные данные. Будут перенаправлены клиенту когда накопиться указанное в первом 32-битном значении данных (или больше).*/
		private var _data : ByteArray = new ByteArray;
		
		private var _connecting : Boolean = false;
		
		private var collector : FosCollector;
		private var transmitter : FosTransmitter;
		
		/** Инициализация. Для подключения необходимо вызвать "Connect()".
		\param host IP-адрес сервера, к которму подключаться.
		\param port Порт подключения.*/
		public function FosClient( host : String, port : int, collector : FosCollector, transmitter : FosTransmitter )
		{
			_host = host;
			_port = port;
			
			this.collector = collector;
			this.transmitter = transmitter;
			
			_socket.endian = Endian.LITTLE_ENDIAN;
			
			_data.endian = Endian.LITTLE_ENDIAN;
			
			_socket.addEventListener( Event.CONNECT, onConnection );
			_socket.addEventListener( ProgressEvent.SOCKET_DATA, onSocketData );
			_socket.addEventListener( Event.CLOSE, onDisconnection );
			_socket.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onSecurityError );
		}
		
		/** Подключение к серверу.*/
		public function Connect() : void
		{
			if ( !_socket.connected )
			{
				_socket.connect( _host, _port );
				_connecting = true;
			}
		}
		
		/** Отключение от сервера. Событие отключения выбрасываться НЕ будет.*/
		public function Disconnect() : void
		{
			try
			{
				_socket.close();
			}
			catch ( e:* )
			{
			}
			_connecting = false;
		}
		/** Синоним Disconnect().*/
		public function Close() : void
		{
			Disconnect();
		}
		
		/** Возвращает true если соединение в данный момент установлено.*/
		public function get connected() : Boolean
		{
			return _socket.connected;
		}
		
		public function get connecting() : Boolean
		{
			return _connecting;
		}
		
		/** Отправка данных на сервер если соединение в данный момент установлено.*/
		public function Send( data : ByteArray ) : void
		{
			if ( _socket.connected )
			{
				_socket.writeBytes( transmitter.Wrap( data ) );
				_socket.flush();
			}
		}
		
		
		private function onConnection( e : Event ) : void
		{
			_connecting = false;
			dispatchEvent( new FosConnectionEvent );
		}
		
		private function onSocketData( e : ProgressEvent ) : void
		{
			//возможно readBytes() перезаписывает предыдущие данные буфера, в который читает, поэтому используем промежуточный:
			var temp : ByteArray = new ByteArray;
			_socket.readBytes( temp );
			//дозаписываем данные в конец массива, иначе они будут перезаписаны на новые:
			_data.position = _data.length;
			_data.writeBytes( temp );
			
			_data.position = 0;
			collector.Collect( _data, function( readyData : ByteArray ) : void
			{
				HandleCollectedData( readyData );
			} );
		}
		
		private function onDisconnection( e : Event ) : void
		{
			_connecting = false;
			_socket.close();
			dispatchEvent( new FosDisconnectionEvent );
		}
		
		private function onIOError( e : IOErrorEvent ) : void
		{
			_connecting = false;
			dispatchEvent(new FosIOErrorEvent);
		}
		
		private function onSecurityError( e : SecurityErrorEvent ) : void
		{
			_connecting = false;
			dispatchEvent( new FosSecurityErrorEvent( e ) );
		}
		
		public function HandleCollectedData( data : ByteArray ) : void
		{
			dispatchEvent( new FosMessageEvent( data ) );
		}
		
		/** Очистить сокет от имеющихся в нём данных.
		\return Количество пропущенных байт.*/
		public function Clear() : int
		{
			var skipped : int = 0;
			while ( _socket.bytesAvailable > 0 )
			{
				++skipped;
				_socket.readByte();
			}
			return skipped;
		}
	}
}



