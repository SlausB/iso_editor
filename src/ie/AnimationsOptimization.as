///@cond
package ie
{
	import blisc.core.BliscAnimation;
	import blisc.core.BliscSprite;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;
	import project_data.AnimationProperties;
	import project_data.SingleResource;
	
	///@endcond
	
	
	/** Truncated frames which can be easily skipped.*/
	public class AnimationsOptimization 
	{
		//to inform user about made optimizations - it's nice to read them:
		public var _animationsOptimizedDueToRequest : int = 0;
		public var _framesSkippedDueToRequest : int = 0;
		public var _animationsOptimizedDueToSimilarity : int = 0;
		public var _framesSkippedDueToSimilarity : int = 0;
		public var _totalAnimationsOptimized : int = 0;
		public var _totalFramesSkipped : int = 0;
		
		public var _animationDescs : Vector.< AnimationDesc > = new Vector.< AnimationDesc >;
		
		
		
		public function ResolveAnimationId(
			name : String,
			editorsPath : String,
			startingFrame : int = 1,
			endingFrame : int = int.MAX_VALUE
		) : int
		{
			for each ( var lookingAnimationDesc : AnimationDesc in _animationDescs )
			{
				if (
					lookingAnimationDesc._name == name &&
					lookingAnimationDesc._editorsPath == editorsPath &&
					lookingAnimationDesc._startingFrame == startingFrame &&
					lookingAnimationDesc._endingFrame == endingFrame
				)
				{
					return lookingAnimationDesc._id;
				}
			}
			
			var newAnimationDesc : AnimationDesc = new AnimationDesc(
				_animationDescs.length + 1,
				name,
				editorsPath,
				startingFrame,
				endingFrame
			);
			
			_animationDescs.push( newAnimationDesc );
			
			return newAnimationDesc._id;
		};
		
		public function PerformOptimization( project : Project, ns : IDataOutput ) : void
		{
			//dunno why it was declared since it's not used anywhere:
			//var pngEncoder : PNGEncoder = new PNGEncoder;
			
			var jpegEncoder : JPEGEncoder = new JPEGEncoder;
			//animation frames sequencing:
			//handling only animations which used within units or complex objects templates:
			ns.writeInt( _animationDescs.length );
			var framesData : ByteArray = new ByteArray;
			for each ( var animationDesc : AnimationDesc in _animationDescs )
			{
				//checking if user specified frame skipping for current animation:
				var foundAnimationProperties : AnimationProperties = null;
				for each ( var sap : AnimationProperties in project._data._animationProperties )
				{
					if ( sap._editorsPath == animationDesc._editorsPath && sap._animationName == animationDesc._name )
					{
						if ( sap._eachFrame > 1 )
						{
							foundAnimationProperties = sap;
						}
						break;
					}
				}
				
				//animation can be optimized here even better: checking for similarity regardless white-space, but not for now...
				
				var ssr : SingleResource = new SingleResource;
				ssr.Init( animationDesc._editorsPath, animationDesc._name );
				
				var sequencingAnimation : MovieClip = ssr.Display( project ) as MovieClip;
				
				if ( sequencingAnimation == null )
				{
					PopUp.Show( "Sequencing animation couldn't displayed", PopUp.POP_UP_ERROR );
					return;
				}
				
				//for current purpose (generating ATF data instead of sequencing writing) it's not needed:
				/*//animations consisting from just 1 frame are fine:
				if ( sequencingAnimation.totalFrames < 2 )
				{
					continue;
				}*/
				
				ns.writeFloat( 1.0 / project.FindResource( animationDesc._editorsPath )._FPS );
				
				//to inform user about changes:
				var requestOptimizationMentioned : Boolean = false;
				var similarityOptimizationMentioned : Boolean = false;
				var totalOmpimizationMentioned : Boolean = false;
				
				//prepare temp array first and write it only if you're sure something was skipped:
				var resultingFrames : Vector.< int > = new < int >[ 1 ];
				
				var framesCount : int = 0;
				
				//last frame to compare with:
				var lastWrittenFrame : BliscSprite = null;
				var sequencingFrame : BliscSprite = null;
				for ( var sequencingIndex : int = 1; ; ++sequencingIndex )
				{
					if ( sequencingIndex > 1 )
					{
						if ( sequencingFrame != lastWrittenFrame && sequencingFrame != null )
						{
							//disp:
							framesData.writeFloat( 0 );
							framesData.writeFloat( 0 );
							
							//original dimensions:
							framesData.writeInt( sequencingFrame._source.width );
							framesData.writeInt( sequencingFrame._source.height );
							
							//power of two dimensions:
							const powerOfTwoWidth : int = BliscSprite.nextPowerOfTwo( sequencingFrame._source.width );
							const powerOfTwoHeight : int = BliscSprite.nextPowerOfTwo( sequencingFrame._source.height );
							framesData.writeInt( powerOfTwoWidth );
							framesData.writeInt( powerOfTwoHeight );
							
							//DEBUG: checking how fast sources generation will work without this part:
							/*//image data itself:
							var pngData : ByteArray = jpegEncoder.encode( sequencingFrame._source );
							framesData.writeInt( pngData.length );
							framesData.writeBytes( pngData );
							pngData.clear();
							pngData = null;*/
							
							
							lastWrittenFrame = sequencingFrame;
							
							++framesCount;
						}
						
						if ( sequencingIndex > sequencingAnimation.totalFrames )
						{
							break;
						}
						
						BliscAnimation.NextFrame( sequencingAnimation );
					}
					
					if ( foundAnimationProperties != null && sequencingIndex % foundAnimationProperties._eachFrame != 1 )
					{
						++_framesSkippedDueToRequest;
						++_totalFramesSkipped;
						
						if ( requestOptimizationMentioned == false )
						{
							++_animationsOptimizedDueToRequest;
							requestOptimizationMentioned = true;
						}
						
						if ( totalOmpimizationMentioned == false )
						{
							++_totalAnimationsOptimized;
							totalOmpimizationMentioned = true;
						}
						
						continue;
					}
					
					var nextSequencingFrame : BliscSprite = BliscAnimation.RenderFrame( sequencingAnimation );
					
					var differ : Boolean = false;
					if ( sequencingFrame == null )
					{
						differ = true;
					}
					else if (	nextSequencingFrame._source.width != sequencingFrame._source.width ||
								nextSequencingFrame._source.height != sequencingFrame._source.height )
					{
						differ = true;
					}
					//making per-pixel check then:
					else
					{
						//DEBUG: skipping per-pixel check:
						if ( project._data._performPerPixelAnimationsCheck || false )
						{
							for ( var row : int = 0; row < nextSequencingFrame._source.height; ++row )
							{
								for ( var column : int = 0; column < nextSequencingFrame._source.width; ++column )
								{
									if ( nextSequencingFrame._source.getPixel32( column, row ) != sequencingFrame._source.getPixel32( column, row ) )
									{
										differ = true;
										break;
									}
								}
								
								if ( differ )
								{
									break;
								}
							}
						}
						else
						{
							differ = true;
						}
					}
					
					if ( differ )
					{
						sequencingFrame = nextSequencingFrame;
						resultingFrames.push( sequencingIndex );
					}
					else
					{
						++_framesSkippedDueToSimilarity;
						++_totalFramesSkipped;
						
						if ( similarityOptimizationMentioned == false )
						{
							++_animationsOptimizedDueToSimilarity;
							similarityOptimizationMentioned = true;
						}
						
						if ( totalOmpimizationMentioned == false )
						{
							++_totalAnimationsOptimized;
							totalOmpimizationMentioned = true;
						}
					}
				}
				
				ns.writeInt( framesCount );
				
				ns.writeBytes( framesData );
				framesData.clear();
			}
		}
	}

}


