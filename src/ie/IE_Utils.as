///@cond
package ie 
{
	import blisc.Blisc;
	import blisc.BliscAnimation;
	import blisc.BliscComplexTemplate;
	import blisc.BliscComplexWithinCompoundTemplate;
	import blisc.BliscCompound;
	import blisc.BliscCompoundTemplate;
	import blisc.BliscObjectTemplate;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import project_data.ComplexTemplate;
	import project_data.ComplexWithinCompound;
	import project_data.CompoundTemplate;
	import project_data.ObjectTemplate;
	import project_data.SingleResource;
	import utils.Utils;
	
	///@endcond
	
	public class IE_Utils 
	{
		
		/** TODO:
			1: need to use it with some cashing - avoid creating animations for each similar object.
			2: create prope animations from MovieClip's
		*/
		public static function CreateAnimation( singleResource:SingleResource, center:Point, project:Project ): BliscAnimation
		{
			return BliscAnimation.FromMovieClip( singleResource.Display( project ) as MovieClip, project.FindResource( singleResource._resourcePath )._FPS, center, singleResource._name );
		}
		
		public static function ComplexTemplateToBlisc( complex:ComplexTemplate, project:Project ): BliscComplexTemplate
		{
			return new BliscComplexTemplate(
				complex._name,
				CreateAnimation( complex._singleResource, complex._center, project ),
				complex._disp,
				complex._center,
				complex._layer._name,
				complex._tiles.concat()
			);
		}
		
		public static function CreateBliscCompound( opaqueData:*, blisc:Blisc, objectTemplate:ObjectTemplate, project:Project ): BliscCompound
		{
			var bliscObjectTemplate:BliscObjectTemplate;
			
			if ( objectTemplate is ComplexTemplate )
			{
				bliscObjectTemplate = ComplexTemplateToBlisc( objectTemplate as ComplexTemplate, project );
			}
			else
			{
				var compound:CompoundTemplate = objectTemplate as CompoundTemplate;
				var complexes:Vector.< BliscComplexWithinCompoundTemplate > = new Vector.< BliscComplexWithinCompoundTemplate >;
				for each ( var complexWithinCompound:ComplexWithinCompound in compound._consisting )
				{
					complexes.push( new BliscComplexWithinCompoundTemplate(
						ComplexTemplateToBlisc( complexWithinCompound._complex, project ),
						new Point( complexWithinCompound._tileDispX, complexWithinCompound._tileDispY ),
						Utils.FromIso( complexWithinCompound._tileDispX * project.side, complexWithinCompound._tileDispY * project.side, new Point )
					) );
				}
				bliscObjectTemplate = new BliscCompoundTemplate( compound._name, complexes );
			}
			
			var bliscCompound:BliscCompound = new BliscCompound( opaqueData, blisc, bliscObjectTemplate );
			bliscCompound.SetIsoX( 0 );
			bliscCompound.SetIsoY( 0 );
			return bliscCompound;
		}
		
	}

}

