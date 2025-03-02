///@cond
package blisc.core 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	CONFIG::stage3d
	{
		import flash.display3D.textures.Texture;
		import flash.display3D.VertexBuffer3D;
		import flash.display3D.Context3DTextureFormat;
	}
	
	///@endcond
	
	/** Information about how exactly draw specified image - just all parameters needed for "copyPixels()" function.*/
	public class BliscSprite 
	{
		/** Which portion of specified data to draw.*/
		public var _originalWidth : Number;
		public var _originalHeight : Number;
		
		public var _disp : Point;
		
		
		CONFIG::stage3d
		{
			/** 3D texture to use for drawing */
			public var _texture : Texture = null;
			
			/** Power of two.*/
			public var _width : Number;
			/** Power of two.*/
			public var _height : Number;
			
			/** Will be set later, while resulting bitmap computation.*/
			public var _uvCoords : Vector.< Number > = new Vector.< Number >( 8, true );
			
			public var _uvBuffer : VertexBuffer3D;
		}
		
		CONFIG::stage3d == false
		{
			/** Where get data to draw.*/
			public var _source : BitmapData;
			
			public function BliscSprite(
				source : BitmapData,
				originalWidth : Number,
				originalHeight : Number ,
				disp : Point
			)
			{
				_source = source;
				_disp = disp;
				
				_originalWidth = _source.width;
				_originalHeight = _source.height;
			}
		}
		
		/**
		*   Get the next-highest power of two
		*   @param v Value to get the next-highest power of two from
		*   @return The next-highest power of two from the given value
		*/
		public static function nextPowerOfTwo( v : uint ) : uint
		{
			v--;
			v |= v >> 1;
			v |= v >> 2;
			v |= v >> 4;
			v |= v >> 8;
			v |= v >> 16;
			v++;
			return v;
		}
	}

}



