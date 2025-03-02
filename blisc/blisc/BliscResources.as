///@cond
package blisc 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	///@endcond
	
	/** Any created resources already suitable for usage.*/
	public class BliscResources 
	{
		private var _animations:Vector.< BliscAnimation > = new Vector.< BliscAnimation >;
		
		
		/** Just adds already somehow created animation. Where did you get it, hardcoded? OMG!
		\sa Create() .*/
		public function Add( animation:BliscAnimation ): void
		{
			_animations.push( animation );
		}
		
		/** From MovieClip: creates, initializes and adds animation.
		\param 
		*/
		public function AddFromMovieClip( movieClip:MovieClip ): void
		{
			//TODO...
		}
		
		/** From sprite sheet: creates, initilizes and adds animation.
		\param bitmapData Source of graphical data.
		\param name How creating animation must be called.
		\param startX Left position of first frame.
		\param startY Upper position of first frame.
		\param width Width of each frame.
		\param height Height of each frame.
		\param amount How much frames to create.
		\param fps "Frames per second" of creating animation.
		*/
		public function AddFromSpriteSheet( bitmapData:BitmapData, name:String, startX:int, startY:int, width:int, height:int, amount:int, fps:Number ): void
		{
			var frames:Vector.< BliscSprite > = new Vector.< BliscSprite >;
			
			var curX:int = startX;
			var curY:int = startY;
			
			for ( var i:int = 0; i < amount; ++i )
			{
				frames.push( new BliscSprite( bitmapData, new Rectangle( curX, curY, width, height ) ) );
				
				curX += width;
				
				if ( curX >= bitmapData.width )
				{
					curX = 0;
					curY += height;
				}
			}
			
			_animations.push( new BliscAnimation( name, 1.0 / fps, frames ) );
		}
		
		/** Returns animation with specified name or null if not found.*/
		public function Find( name:String ): BliscAnimation
		{
			for each ( var bliscAnimation:BliscAnimation in _animations )
			{
				if ( bliscAnimation.name == name )
				{
					return bliscAnimation;
				}
			}
			
			return null;
		}
		
		/** Create and add animation consisting of single frame specified by class (embedded image).*/
		public function AddFromBitmapClass( bitmap:Class, name:String, dispX:Number = 0, dispY:Number = 0 ): void
		{
			_animations.push( new BliscAnimation( name, 0, new <BliscSprite>[ new BliscSprite( ( ( new bitmap ) as Bitmap ).bitmapData, null, dispX, dispY ) ] ) );
		}
	}

}


