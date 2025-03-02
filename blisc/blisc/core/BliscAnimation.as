///@cond
package blisc.core 
{
	import com.junkbyte.console.Cc;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import spark.primitives.Rect;
	
	///@endcond
	
	/** Series of sprites with specified gap between each frame and graphical data for each sprite.*/
	public class BliscAnimation 
	{
		/** To bind from units and complex descriptors.*/
		public var _id : int;
		
		/** How much seconds to wait between switching from frame to frame.*/
		public var _gap : Number = 1.0;
		
		/** Frames to draw.*/
		public var _frames : Vector.< BliscSprite > = null;
		
		/** Custom gaps for each (after) frame if needed. Must correspond to frames number.*/
		public var _customGaps : Vector.< Number > = null;
		
		/** Human-readable name which differs this animation from any other. Can be freely omitted (null).*/
		public var _name : String;
		
		/** How much seconds needed to play all frames of animation.*/
		public var _period : Number = 0;
		
		
		public function BliscAnimation(
			id : int,
			gap : Number,
			frames : Vector.< BliscSprite >,
			customGaps : Vector.< Number > = null,
			name : String = null
		)
		{
			_id = id;
			_gap = gap;
			_frames = frames;
			_customGaps = customGaps;
			if ( customGaps == null )
			{
				_period = _gap * _frames.length;
			}
			else
			{
				if ( customGaps.length != frames.length )
				{
					Cc.error( "E: BliscAnimation.BliscAnimation(): wrong custom gaps." );
				}
				
				for each ( var customGap : Number in customGaps )
				{
					_period += customGap;
				}
			}
			_name = name;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		/** Resolve frame if animation was played specified amount of seconds.*/
		public function Resolve( played : Number = 0, cycle : Boolean = true ) : BliscSprite
		{
			if ( played == 0 )
			{
				return _frames[ 0 ];
			}
			
			if ( _frames.length == 1 )
			{
				return _frames[ 0 ];
			}
			
			var position : Number;
			
			if ( cycle )
			{
				position = played % _period;
			}
			else
			{
				if ( played >= _period )
				{
					return last;
				}
				
				position = played;
			}
			
			if ( _customGaps == null )
			{
				var frameIndex : int = Math.floor( position / _gap );
				//dunno why but sometimes (not on my PC) index is getting larger than array's length - 1, so cycle it:
				if ( frameIndex >= _frames.length )
				{
					return last;
					frameIndex = 0;
				}
				//you know what? After 10 years this project is built again with latest AirSDK (which isn't even from Adobe anymore) and now frameIndex becomes < 0!
				if ( frameIndex < 0 ) {
					frameIndex = 0;
				}
				return _frames[ frameIndex ];
			}
			else
			{
				var pos : Number = 0;
				const length : int = _customGaps.length;
				for ( var i : int = 0; i < _customGaps.length; ++i )
				{
					pos += _customGaps[ i ];
					if ( pos > position )
					{
						return _frames[ i ];
					}
				}
			}
			
			//getting here if cycle is true and played specified bigger than _period:
			return last;
		}
		
		/** Returns frame at specified index independently of gaps, animation time and so on.*/
		public function At( index : int ) : BliscSprite
		{
			return _frames[ index ];
		}
		
		private static function GotoAndStop( root : MovieClip, frame : int ) : void
		{
			root.gotoAndStop( frame );
			
			for ( var childIndex : int = 0; childIndex < root.numChildren; ++childIndex )
			{
				var child : MovieClip = root.getChildAt( childIndex ) as MovieClip;
				if ( child != null )
				{
					GotoAndStop( child, frame );
				}
			}
		}
		
		public static function NextFrame( root : MovieClip ) : void
		{
			//let's thing, for now, that all embedded animations must be played infinitely (if will be used single animation somewhere, can be tuned using frame labels, for example):
			//if reached last frame:
			if ( root.currentFrame >= root.totalFrames )
			{
				root.gotoAndStop( 0 );
			}
			else
			{
				root.nextFrame();
			}
			
			for ( var childIndex : int = 0; childIndex < root.numChildren; ++childIndex )
			{
				var child : MovieClip = root.getChildAt( childIndex ) as MovieClip;
				if ( child != null )
				{
					NextFrame( child );
				}
			}
		}
		
		/** Renders current frame and returns it.*/
		public static function RenderFrame( of : MovieClip, name : String = null ) : BliscSprite
		{
			//resolving frame's bounds:
			var bounds : Rectangle = of.getBounds( of );
			bounds.x = Math.floor( bounds.x );
			bounds.y = Math.floor( bounds.y );
			bounds.width = Math.ceil( bounds.width );
			bounds.height = Math.ceil( bounds.height );
			
			if ( bounds.width <= 0 || bounds.height <= 0 )
			{
				Cc.error( "E: BliscAnimation.RenderFrame(): empty frame at position \"" + of.currentFrame.toString() + "\" within animation \"" + ( name == null ? of.name : name ) + "\". Fix it." );
			}
			else
			{
				var matrix : Matrix = of.transform.matrix;
				matrix.translate( - bounds.x, - bounds.y );
				
				var bitmapData : BitmapData = new BitmapData( bounds.width, bounds.height, true, 0 );
				bitmapData.draw( of, matrix );
				
				return new BliscSprite( bitmapData, bitmapData.rect.width, bitmapData.rect.height, new Point( bounds.x, bounds.y ) );
			}
			
			return null;
		}
		
		/**
		\param name Human-readable name which differs this animation from any other. Can be freely omitted (null). Will be applied on animation if not null. Otherwise source.name will be used.
		\param startingFrame Which frame to use as a starting frame (inclusive).
		\param endingFrame On which frame to stop forming the animation before reaching MovieClip's end (inclusive).
		\param skipDuplicates True if frames must be checked for per-pixel similarities and skipped such.
		\param eachFrame Which each frame resulting animation must have. Say, original animation has frames '1, 2, 3, 4, 5, 6, 7, 8', if 'each value' is set to 3, then resulting animation will be '1, 4, 7'. Time gaps will be properly keepen (time to play '1, 4, 7' animation will be the same as '1, 2, 3, 4, 5, 6, 7, 8'.
		*/
		public static function FromMovieClip(
			source : MovieClip,
			FPS : Number,
			name : String = null,
			startingFrame : int = 0,
			endingFrame : int = int.MAX_VALUE
		) : BliscAnimation
		{
			if ( startingFrame < 1 )
			{
				startingFrame = 1;
			}
			if ( endingFrame < 1 )
			{
				endingFrame = int.MAX_VALUE;
			}
			
			var frames : Vector.< BliscSprite > = new Vector.< BliscSprite >;
			
			var i : int = startingFrame;
			GotoAndStop( source, i );
			for ( ; i <= endingFrame; ++i )
			{
				if ( i > source.totalFrames )
				{
					break;
				}
				
				var frame : BliscSprite = RenderFrame( source, name );
				if ( frame != null )
				{
					frames.push( frame );
				}
				
				NextFrame( source );
			}
			
			return new BliscAnimation( 1.0 / FPS, -1, frames, null, name == null ? source.name : name );
		}
		
		/** Frames can only grow in number.*/
		public static function FromSequence(
			source : MovieClip,
			FPS : Number,
			sequence : Vector.< int >,
			startingFrame : int = 0,
			endingFrame : int = int.MAX_VALUE,
			name : String = null
		) : BliscAnimation
		{
			if ( startingFrame < 1 )
			{
				startingFrame = 1;
			}
			if ( endingFrame < 1 )
			{
				endingFrame = int.MAX_VALUE;
			}
			
			if ( sequence.length <= 0 )
			{
				Cc.error( "E: BliscAnimation.FromSuquence(): no frames within sequence." );
				return null;
			}
			
			var frames : Vector.< BliscSprite > = new Vector.< BliscSprite >;
			
			const gap : Number = 1.0 / FPS;
			var customGaps : Vector.< Number > = new Vector.< Number >;
			
			var sequenceIndex : int = 0;
			
			for ( var i : int = startingFrame; ; ++i )
			{
				//keeping last frame visible:
				if ( customGaps.length > 0 )
				{
					customGaps[ customGaps.length - 1 ] += gap;
				}
				
				if ( i > source.totalFrames )
				{
					break;
				}
				
				//progressing when not on starting frame:
				if ( i > startingFrame )
				{
					NextFrame( source );
				}
				
				//filling with waiting till inexistent last frame will be displayed and handled:
				if ( sequenceIndex >= sequence.length )
				{
					continue;
				}
				
				//can happen in 2 cases: 1 - starting frame specified BEFORE next appearing sequences frame - wait till he first some appear; 2 - some sequenced frame already enqueued - waiting till some another:
				if ( i < sequence[ sequenceIndex ] )
				{
					continue;
				}
				
				var frame : BliscSprite = RenderFrame( source );
				if ( frame != null )
				{
					frames.push( frame );
				}
				
				customGaps.push( 0 );
				
				//frame rendered and enqueued - progressing within sequence:
				++sequenceIndex;
			}
			
			return new BliscAnimation(
				gap,
				-1,
				frames,
				customGaps,
				name == null ? source.name : name
			);
		}
		
		/** How much seconds needed to play all frames of animation.*/
		public function get period() : Number
		{
			return _period;
		}
		
		/** Returns the first frame.*/
		public function get first() : BliscSprite
		{
			if ( _frames.length < 1 )
			{
				return null;
			}
			
			return _frames[ 0 ];
		}
		
		/** Returns the last frame.*/
		public function get last() : BliscSprite
		{
			if ( _frames.length < 1 )
			{
				return null;
			}
			
			return _frames[ _frames.length - 1 ];
		}
		
	}

}


