///@cond
package project_data
{
	import blisc.BliscAnimation;
	import blisc.BliscSprite;
	import blisc.templates.BliscUnitTemplate;
	import blisc.templates.BliscUnitView;
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
		public var _units:Vector.< UnitDesc > = new Vector.< UnitDesc >;
		
		
		public function Init( applicationDomain:ApplicationDomain, names:Array, FPS:Number, main:Main ): void
		{
			//dunno why but it's null while loading:
			if ( _units == null )
			{
				_units = new Vector.< UnitDesc >;
			}
			
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
				
				
				var currentLabels:Array = unitGraphics.currentLabels;
				
				//remove all labels which doesn't display any orientation:
				for ( var splicingLabelIndex:int = 0; splicingLabelIndex < currentLabels.length; ++splicingLabelIndex )
				{
					if ( Orientation.ToInt( currentLabels[ splicingLabelIndex ].name ) == Orientation.U )
					{
						currentLabels.splice( splicingLabelIndex );
						--splicingLabelIndex;
					}
				}
				
				if ( currentLabels.length <= 0 )
				{
					main.PopUp( "Not a single orientation was specified for unit \"" + name + "\". It will not be displayed within \"Units\" list.", Main.POP_UP_WARNING );
					continue;
				}
				
				var bliscUnitTemplate : BliscUnitTemplate = new BliscUnitTemplate( name );
				
				var unitsSingleResource:SingleResource = new SingleResource;
				unitsSingleResource.Init( _path, name );
				
				var unitDesc:UnitDesc = new UnitDesc( bliscUnitTemplate, unitsSingleResource );
				_units.push( unitDesc );
				
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
					unitDesc._template._views.push( new BliscUnitView( orientation, bliscAnimation ) );
				}
			}
		}
		
	}

}

