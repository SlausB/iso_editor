///@cond
package ie 
{
	import blisc.core.Blisc;
	import blisc.core.BliscAnimation;
	import blisc.instances.BliscCompound;
	import blisc.templates.BliscComplexTemplate;
	import blisc.templates.BliscComplexWithinCompoundTemplate;
	import blisc.templates.BliscCompoundTemplate;
	import blisc.templates.BliscLayerTemplate;
	import blisc.templates.BliscObjectTemplate;
	import blisc.templates.BliscRegionWithinComplex;
	import blisc.templates.BliscRegion;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import project_data.ComplexTemplate;
	import project_data.ComplexWithinCompound;
	import project_data.CompoundTemplate;
	import project_data.Layer;
	import project_data.ObjectTemplate;
	import project_data.RegionWithinComplex;
	import project_data.SingleResource;
	import utils.Utils;
	
	///@endcond
	
	public class IE_Utils 
	{
		private static var _animationsCache : Vector.< CachedAnimation > = null;
		
		/** TODO:
			1: need to use it with some cashing - avoid creating animations for each similar object - done.
			2: create proper animations from MovieClip's - seems like done with some assumptions (cycled embedded MovieClips) and limitations (inability to execute code within frames).
		*/
		public static function CreateAnimation( singleResource : SingleResource, project : Project ) : BliscAnimation
		{
			if ( _animationsCache == null )
			{
				_animationsCache = new Vector.< CachedAnimation >;
			}
			
			//trying to look within cache:
			for each ( var cachedAnimation : CachedAnimation in _animationsCache )
			{
				if ( cachedAnimation._resource._name == singleResource._name && cachedAnimation._resource._resourcePath == singleResource._resourcePath )
				{
					return cachedAnimation._animation;
				}
			}
			
			var newAnimation : BliscAnimation = BliscAnimation.FromMovieClip( singleResource.Display( project ) as MovieClip, project.FindResource( singleResource._resourcePath )._FPS, singleResource._name );
			
			_animationsCache.push( new CachedAnimation( singleResource, newAnimation ) );
			
			return newAnimation;
		}
		
		/** Any object template (ComplexTemplate or CompoundTemplate for now) to corresponding Blisc template.*/
		public static function ObjectTemplateToBlisc( regionsCache : Vector.< BliscRegion >, object : ObjectTemplate, project : Project ) : BliscObjectTemplate
		{
			if ( object is ComplexTemplate )
			{
				return ComplexTemplateToBlisc( regionsCache, object as ComplexTemplate, project );
			}
			else
			{
				var compound : CompoundTemplate = object as CompoundTemplate;
				var complexes : Vector.< BliscComplexWithinCompoundTemplate > = new Vector.< BliscComplexWithinCompoundTemplate >;
				for each ( var complexWithinCompound : ComplexWithinCompound in compound._consisting )
				{
					complexes.push( new BliscComplexWithinCompoundTemplate(
						ComplexTemplateToBlisc( regionsCache, complexWithinCompound._complex, project ),
						new Point( complexWithinCompound._tileDispX, complexWithinCompound._tileDispY ) )
					);
				}
				return new BliscCompoundTemplate( compound._name, complexes );
			}
		}
		
		public static function ComplexTemplateToBlisc( regionsCache : Vector.< BliscRegion >, complex : ComplexTemplate, project : Project ) : BliscComplexTemplate
		{
			//again - use some caching here - create all regions (BliscRegion) only once:
			var regions : Vector.< BliscRegionWithinComplex > = new Vector.< BliscRegionWithinComplex >;
			for each ( var regionWithinComplex : RegionWithinComplex in complex._regions )
			{
				var bliscRegion : BliscRegion = Isometry.ObtainBliscRegion( regionWithinComplex._region, regionsCache );
				
				var bliscTiles : Vector.< Point > = new Vector.< Point >;
				for each ( var tile : Point in regionWithinComplex._tiles )
				{
					bliscTiles.push( tile.clone() );
				}
				
				var bliscRegionWithinComplex : BliscRegionWithinComplex = new BliscRegionWithinComplex( bliscRegion, bliscTiles );
				regions.push( bliscRegionWithinComplex );
			}
			
			return new BliscComplexTemplate(
				complex._name,
				-1,
				CreateAnimation( complex._singleResource, project ),
				complex._disp,
				complex._center,
				complex._layer == null ? Blisc.LAYER_DEFAULT : complex._layer._name,
				regions,
				complex._interactive
			);
		}
		
		public static function CreateBliscCompound( regionsCache : Vector.< BliscRegion >, opaqueData : *, blisc : Blisc, objectTemplate : ObjectTemplate, project : Project ) : BliscCompound
		{
			var bliscObjectTemplate : BliscObjectTemplate = ObjectTemplateToBlisc( regionsCache, objectTemplate, project );
			
			return new BliscCompound( opaqueData, blisc, bliscObjectTemplate );
		}
		
		public static function LayerToBlisc( layer : Layer ) : BliscLayerTemplate
		{
			return new BliscLayerTemplate( layer._name, layer._units, layer._selectable );
		}
		
	}

}
import blisc.core.BliscAnimation;
import project_data.SingleResource;

class CachedAnimation
{
	public var _resource : SingleResource;
	public var _animation : BliscAnimation;
	
	
	public function CachedAnimation( resource : SingleResource, animation : BliscAnimation )
	{
		_resource = resource;
		_animation = animation;
	}
}



