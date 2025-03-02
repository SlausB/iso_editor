package ie 
{
	import blisc.templates.BliscUnitView;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import fos.FosUtils;
	import project_data.ComplexWithinCompound;
	import project_data.Layer;
	import project_data.Map;
	import project_data.ObjectInstance;
	import project_data.ObjectTemplate;
	import project_data.ProjectData;
	import project_data.Region;
	import project_data.RegionWithinComplex;
	import project_data.Resource;
	import project_data.UnitProperties;
	import project_data.ComplexTemplate;
	import project_data.CompoundTemplate;

	public class Gen 
	{
		/** Write down just all the data to be completely read as binary.*/
		public static function AllBinary( directory : File, d : ProjectData ) {
			var file : File = directory.resolvePath( "blisc.bin" );
			var bin : FileStream = new FileStream;
			bin.open( file, FileMode.WRITE );
			
			f( bin, d._tileSize );
            f( bin, d.side );
			n( bin, d._slippingValue );
			n( bin, d._throughAlpha );
			
			n( bin, d._regions.length );
			for each ( var r : Region in d._regions ) {
				s( bin, r._name );
				n( bin, r._type );
			}
			
			n( bin, d._layers.length );
			for each ( var l : Layer in d._layers ) {
				s( bin, l._name );
				b( bin, l._units );
				b( bin, l._visible );
				b( bin, l._selectable );
			}
			
			resources( bin, d );
			
			const complexes : Vector.< ComplexTemplate > = new Vector.< ComplexTemplate >();
			const compounds : Vector.< CompoundTemplate > = new Vector.< CompoundTemplate >();
			for each ( var c : ObjectTemplate in d._objects ) {
				const complex : ComplexTemplate = c as ComplexTemplate;
				const compound : CompoundTemplate = c as CompoundTemplate;
				
				if ( complex != null ) {
					complexes.push( complex );
				}
				if ( compound != null ) {
					compounds.push( compound );
				}
			}
			
			n( bin, complexes.length );
			for each ( var cx : ComplexTemplate in complexes ) {
				s( bin, cx._name );
				
				//regions:
				n( bin, cx._regions.length );
				for each ( var regionWithinComplex : RegionWithinComplex in cx._regions ) {
					//tiles which current region occupies:
					n( bin, regionWithinComplex._tiles.length );
					for each ( var tile : Point in regionWithinComplex._tiles ) {
						f( bin, tile.x );
						f( bin, tile.y );
					}
					
					//region index:
					n( bin, d._regions.indexOf( regionWithinComplex._region ) );
				}
				
				//animation index:
				s( bin, cx._singleResource._name );
				s( bin, cx._singleResource._resourcePath );
				
				f( bin, cx._disp.x );
				f( bin, cx._disp.y );
				
				f( bin, cx._center.x );
				f( bin, cx._center.y );
				
				s( bin, cx._layer._name );
				
				b( bin, cx._interactive );
			}
			
			n( bin, compounds.length );
			for each ( var cd : CompoundTemplate in compounds ) {
				s( bin, cd._name );
				
				n( bin, cd._consisting.length );
				for each ( var compoundConsisting : ComplexWithinCompound in cd._consisting )
				{
					s( bin, compoundConsisting._complex._name );
					
					f( bin, compoundConsisting._tileDispX );
					f( bin, compoundConsisting._tileDispY );
				}
			}
			
			n( bin, d._maps.length );
			for each ( var m : Map in d._maps ) {
				s( bin, m._name );
				
				n( bin, m._instances.length );
				for each ( var i : ObjectInstance in m._instances ) {
					s( bin, i._template._name );
					f( bin, i._tileCoords.x );
					f( bin, i._tileCoords.y );
				}
				
				n( bin, m._right );
				n( bin, m._down );
				b( bin, m._clampToTiles );
				f( bin, m._unitsSpeed );
			}
		}
		
		public static function resources( bin : FileStream, d : ProjectData ) {
			n( bin, d._resources.length );
			for each ( var res : Resource in d._resources ) {
				s( bin, res._path );
				
				n( bin, res._units.length );
				for each ( var ud : UnitDesc in res._units )
				{
					const unitProperties : UnitProperties = d.FindUnitProperties( ud, true );
					
					//surfaces:
					//surfaces amount:
					n( bin, unitProperties._surfaces.length );
					//surfaces itself:
					for each ( var surfaceWithinUnit : Region in unitProperties._surfaces )
					{
						n( bin, d._regions.indexOf( surfaceWithinUnit ) );
					}
					
					//unit views:
					//views amount:
					n( bin, ud._template._views.length );
					//views itself:
					for ( var unitViewIndex : int = 0; unitViewIndex < ud._template._views.length; ++ unitViewIndex )
					{
						const unitView : BliscUnitView = ud._template._views[ unitViewIndex ];
						const unitViewOrientation : UnitOrientation = ud._orientations[ unitViewIndex ];
						
						n( bin, unitViewOrientation._orientation );
						
						//animation:
						s( bin, ud._singleResource._name );
						s( bin, ud._singleResource._resourcePath );
						n( bin, unitViewOrientation._startingFrame );
						n( bin, unitViewOrientation._endingFrame );
					}
					
					//refused redirections:
					n( bin, unitProperties._refusedDirections.length );
					for each ( var refused : int in unitProperties._refusedDirections ) {
						n( bin, refused );
					}
					
					s( bin, ud._template._name );
					s( bin, ud._template._animation );
				}
			}
		}
		
		/** Output integer value.*/
		public static function n( f : FileStream, v : int ) {
			FosUtils.WriteLEB128_u32( f, v );
		}
		/** Output boolean value.*/
		public static function b( f : FileStream, v : Boolean ) {
			FosUtils.WriteLEB128_u32( f, v ? 1 : 0 );
		}
		/** Write UTF string.*/
		public static function s( f : FileStream, s : String ) {
			n( f, s.length );
			f.writeUTFBytes( s );
		}
		/** Write real (float) value.*/
		public static function f( f : FileStream, v : Number ) {
			s( f, v.toString() );
		}
	}

}