///@cond
package ie 
{
	import blisc.core.Blisc;
	import blisc.core.BliscAnimation;
	import blisc.instances.BliscCompound;
	import blisc.templates.BliscComplexTemplate;
	import blisc.templates.BliscComplexWithinCompoundTemplate;
	import blisc.templates.BliscCompoundTemplate;
	import blisc.templates.BliscObjectTemplate;
	import blisc.templates.BliscRegionWithinComplex;
	import blisc.templates.BliscRegion;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import project_data.ComplexTemplate;
	import project_data.ComplexWithinCompound;
	import project_data.CompoundTemplate;
	import project_data.ObjectTemplate;
	import project_data.RegionWithinComplex;
	import project_data.SingleResource;
	import utils.Utils;
	
	///@endcond
	
	public class IE_Utils 
	{
		
		/** TODO:
			1: need to use it with some cashing - avoid creating animations for each similar object.
			2: create prope animations from MovieClip's
		*/
		public static function CreateAnimation( singleResource : SingleResource, center : Point, project : Project ) : BliscAnimation
		{
			return BliscAnimation.FromMovieClip( singleResource.Display( project ) as MovieClip, project.FindResource( singleResource._resourcePath )._FPS, center, singleResource._name );
		}
		
		public static function ComplexTemplateToBlisc( regionsCache : Vector.< BliscRegion >, complex : ComplexTemplate, project : Project ) : BliscComplexTemplate
		{
			//again - use some caching here - create all regions (BliscRegion) only once:
			var regions:Vector.< BliscRegionWithinComplex > = new Vector.< BliscRegionWithinComplex >;
			for each ( var regionWithinComplex : RegionWithinComplex in complex._regions )
			{
				var bliscRegion : BliscRegion = Isometry.ObtainBliscRegion( regionWithinComplex._region, regionsCache );
				
				var bliscTiles:Vector.< Point > = new Vector.< Point >;
				for each ( var tile:Point in regionWithinComplex._tiles )
				{
					bliscTiles.push( tile.clone() );
				}
				
				var bliscRegionWithinComplex:BliscRegionWithinComplex = new BliscRegionWithinComplex( bliscRegion, bliscTiles );
				regions.push( bliscRegionWithinComplex );
			}
			
			return new BliscComplexTemplate(
				complex._name,
				CreateAnimation( complex._singleResource, complex._center, project ),
				complex._disp,
				complex._center,
				complex._layer._name,
				regions
			);
		}
		
		public static function CreateBliscCompound( regionsCache : Vector.< BliscRegion >, opaqueData : *, blisc : Blisc, objectTemplate : ObjectTemplate, project : Project ) : BliscCompound
		{
			var bliscObjectTemplate : BliscObjectTemplate;
			
			if ( objectTemplate is ComplexTemplate )
			{
				bliscObjectTemplate = ComplexTemplateToBlisc( regionsCache, objectTemplate as ComplexTemplate, project );
			}
			else
			{
				var compound:CompoundTemplate = objectTemplate as CompoundTemplate;
				var complexes:Vector.< BliscComplexWithinCompoundTemplate > = new Vector.< BliscComplexWithinCompoundTemplate >;
				for each ( var complexWithinCompound : ComplexWithinCompound in compound._consisting )
				{
					complexes.push( new BliscComplexWithinCompoundTemplate(
						ComplexTemplateToBlisc( regionsCache, complexWithinCompound._complex, project ),
						new Point( complexWithinCompound._tileDispX, complexWithinCompound._tileDispY ) )
					);
				}
				bliscObjectTemplate = new BliscCompoundTemplate( compound._name, complexes );
			}
			
			var bliscCompound : BliscCompound = new BliscCompound( opaqueData, blisc, bliscObjectTemplate );
			bliscCompound.SetIsoXY( 0, 0 );
			return bliscCompound;
		}
		
	}

}

