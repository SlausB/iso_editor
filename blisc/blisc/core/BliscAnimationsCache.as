///@cond
package blisc.core
{
	import flash.display3D.Context3DTextureFormat;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	
	///@endcond
	
	
	/** Stores all animations which can be used within current map. The whole animations data file is loaded into this object.*/
	public class BliscAnimationsCache
	{
		public var _animations : Vector.< BliscAnimation >;
		
		
		public function Upload( batch : BliscBatch, ns : IDataInput ) : void
		{
			const animationsCount : int = ns.readInt();
			_animations = new Vector.< BliscAnimation >( animationsCount, true );
			
			var imageData : ByteArray = new ByteArray;
			
			for ( var i : int = 0; i < animationsCount; ++i )
			{
				const gap : Number = ns.readFloat();
				
				const framesCount : int = ns.readInt();
				var frames : Vector.< BliscSprite > = new Vector.< BliscSprite >( framesCount, true );
				for ( var frameIndex : int = 0; frameIndex < framesCount; ++frameIndex )
				{
					var s : BliscSprite = new BliscSprite;
					
					s._disp = new Point( ns.readFloat(), ns.readFloat() );
					
					s._originalWidth = ns.readInt();
					s._originalHeight = ns.readInt();
					
					s._width = ns.readInt();
					s._height = ns.readInt();
					
					ns.readBytes( imageData, 0, ns.readInt() );
					
					
					s._uvCoords[ 0 ] = 0;								s._uvCoords[ 1 ] = s._originalHeight / s._height;
					s._uvCoords[ 2 ] = 0;								s._uvCoords[ 3 ] = 0;
					s._uvCoords[ 4 ] = s._originalWidth / s._width;		s._uvCoords[ 5 ] = 0;
					s._uvCoords[ 6 ] = s._originalWidth / s._width;		s._uvCoords[ 7 ] = s._originalHeight / s._height;
					
					s._uvBuffer = batch._context3D.createVertexBuffer( s._uvCoords.length / 2, 2 );
					s._uvBuffer.uploadFromVector( s._uvCoords, 0, s._uvCoords.length / 2 );
					
					s._texture = batch._context3D.createTexture(
						s._width,
						s._height,
						Context3DTextureFormat.COMPRESSED_ALPHA,
						false
					);
					
					s._texture.uploadCompressedTextureFromByteArray( imageData, 0 );
					imageData.clear();
					
					
					frames[ frameIndex ] = s;
				}
				
				var customGaps : Vector.< Number > = null;
				if ( bnss.readBoolean() )
				{
					customGaps = new Vector.< Number >( framesCount, true );
					
					for ( var customGap : int = 0; customGap < framesCount; ++customGap )
					{
						customGaps[ customGap ] = bs.readFloat();
					}
				}
				
				_animations[ i ] = new BliscAnimation( i + 1, gap, frames, customGaps, ns.readUTF() );
			}
		}
	}

}



