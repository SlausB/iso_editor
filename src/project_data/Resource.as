///@cond
package project_data
{
	import blisc.BliscAnimation;
	import blisc.BliscSprite;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import iso.orient.Orientation;
	import org.osmf.layout.AnchorLayoutMetadata;
	///@endcond
	
	/** SWF file with graphical resources.*/
	public class Resource 
	{
		public var _path:String;
		
		public var _applicationDomain:ApplicationDomain;
		
		/** [ String ].*/
		public var _names:Array;
		
		/** The nominal frame rate, in frames per second, of the loaded SWF file. This
		 * number is often an integer, but need not be.*/
		public var _FPS:Number;
		
		/** Recognized units' specifications.*/
		public var _units:Vector.< UnitDesc >;
		
		
		public function Init( applicationDomain:ApplicationDomain, names:Array, FPS:Number ): void
		{
			_applicationDomain = applicationDomain;
			
			_names = names;
			
			_FPS = FPS;
			
			//recognizing units:
			for each ( var name:String in _names )
			{
				var parts:Array = name.split( "_" );
				//units must start with "unit_" and be like "unit_move_name":
				if ( parts.length < 3 || parts[ 0 ] != "unit" )
				{
					continue;
				}
				
				var unitGraphics:MovieClip = ( new ( _applicationDomain.getDefinition( name ) as Class ) ) as MovieClip;
				if ( unitGraphics == null )
				{
					continue;
				}
				
				var unitsSingleResource:SingleResource = new SingleResource;
				unitsSingleResource.Init( _path, name );
				var unitDesc:UnitDesc = new UnitDesc( name, unitsSingleResource );
				_units.push( unitDesc );
				
				var currentLabels:Array = unitGraphics.currentLabels;
				for ( var splicingLabelIndex:int = 0; splicingLabelIndex < currentLabels.length; ++splicingLabelIndex )
				{
					if ( Orientation.ToInt( currentLabels[ splicingLabelIndex ].name ) == Orientation.U )
					{
						currentLabels.splice( splicingLabelIndex );
						--splicingLabelIndex;
					}
				}
				for ( var currentLabelIndex:int = 0; currentLabelIndex < currentLabels.length; ++currentLabelIndex )
				{
					var frameLabel:FrameLabel = currentLabels[ currentLabelIndex ] as FrameLabel;
					var orientation:int = Orientation.ToInt( frameLabel.name );
					var endingFrame:int = int.MAX_VALUE;
					if ( ( currentLabelIndex + 1 ) < currentLabels.length )
					{
						endingFrame = currentLabels[ currentLabelIndex + 1 ].frame;
					}
					var bliscAnimation:BliscAnimation = BliscAnimation.FromMovieClip( unitGraphics, _FPS, new Point, name, frameLabel.frame, endingFrame );
					unitDesc._views.push( new UnitView( orientation, bliscAnimation ) );
				}
			}
		}
		
	}

}

