///@cond
package fos
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	///@endcond
	
	public class FosUtils 
	{
		
		public static function WriteString( output : IDataOutput, string : String ) : void
		{
			var tmp : ByteArray = new ByteArray;
			tmp.endian = Endian.LITTLE_ENDIAN;
			tmp.writeUTFBytes( string );
			WriteLEB128_u32( output, tmp.length );
			output.writeBytes( tmp );
		}
		
		public static function ReadString( input : IDataInput ) : String
		{
			const length : uint = ReadLEB128_u32( input );
			return input.readUTFBytes( length );
		}
		
		public static function ReadLEB128_32( input : IDataInput ) : int
		{
			var result : int = 0;
			var shift : int = 0;
			const size : int = 32;
			for ( ;; )
			{
				if ( input.bytesAvailable < 1 )
				{
					return 0;
				}
				var byte : int = input.readByte();
				
				result |= ( ( byte & 0x7F ) << shift );
				shift += 7;
				/* sign bit of byte is second high order bit (0x40) */
				if ( ( byte & 0x80 ) == 0 )
				{
					break;
				}
			}
			//if left something to fill for negative value:
			if ( ( shift < size ) && ( result & ( 1 << ( shift - 1 ) ) ) )
			{
				/* sign extend */
				result |= -( 1 << shift );
			}
			
			return result;
		}
		
		public static function ReadLEB128_u32( input : IDataInput ) : uint
		{
			var result : int = 0;
			var shift : int = 0;
			for ( ;; )
			{
				if ( input.bytesAvailable < 1 )
				{
					return 0;
				}
				var byte : int = input.readByte();
				
				result |= ( ( byte & 0x7F ) << shift );
				if ( ( byte & 0x80 ) == 0 )
				{
					break;
				}
				shift += 7;
			}
			
			return result;
		}
		
		public static function WriteLEB128_32( output : IDataOutput, value : int ) : void
		{
			var more : Boolean = true;
			const negative : Boolean = value < 0;
			const size : int = 32;
			for ( ;; )
			{
				var byte : int = value & 0x0000007F;
				value >>= 7;
				//the following is unnecessary if the implementation of >>= uses an arithmetic rather than logical shift for a signed left operand
				if ( negative )
				{
					/* sign extend */
					value |= -( 1 << ( size - 7 ) );
				}
				/* sign bit of byte is second high order bit (0x40) */
				if ( ( value == 0 && ( byte & 0x40 ) == 0 ) || ( value == -1 && byte & 0x40 ) )
				{
					more = false;
				}
				else
				{
					byte |= 0x80;
				}
				output.writeByte( byte );
			}
		}
		
		public static function WriteLEB128_u32( output : IDataOutput, value : uint ) : void
		{
			//при передаче отрицательных знаковых чисел они преобазовываются в большие числа, которые не могу записаться из-за вечного цикла:
			if ( value > 0x7f7f7f )
			{
				value = 0;
			}
			
			do
			{
				var byte : int = value & 0x7F;
				value >>= 7;
				if ( value != 0 ) /* more bytes to come */
				{
					byte |= 0x80;
				}
				output.writeByte( byte );
			}
			while ( value != 0 );
		}
		
		/** Read object from stream written using AS3's AMF.*/
		public static function ReadAMF( input : IDataInput ) : Object
		{
			//just skip length specifier - AS3 will read object by it's own:
			ReadLEB128_u32( input );
			return input.readObject();
		}
		
		/** Write object to stream using AS3's AMF.
		\param temp Specify some ByteArray to speed up writing process (avoiding temp object creation).
		*/
		public static function WriteAMF( output : IDataOutput, object : Object, temp : ByteArray = null ) : void
		{
			if ( temp == null )
			{
				temp = new ByteArray;
			}
			else
			{
				temp.position = 0;
			}
			
			temp.writeObject( object );
			WriteLEB128_u32( output, temp.position );
			output.writeBytes( temp );
		}
		
	}

}



