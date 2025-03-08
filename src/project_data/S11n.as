package project_data {

	import com.junkbyte.console.Cc;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.events.Event;
	import flash.geom.Point;
    import ie.PopUp;

    public class S11n {

        /** Serialize to JSON.*/
        public static function write( data : ProjectData, path : String ) {
            try {
                //var file : File = new File( path );
                var file : File = File.applicationDirectory.resolvePath( path );
                var fileStream : FileStream = new FileStream();
                
                var json : Object = project_to_json( data );
                var jsonString : String = JSON.stringify( json, null, 4 ); // Pretty-printing with indentation
                
                try
                {
                    fileStream.open( file, FileMode.WRITE );
                }
                catch ( e : Error )
                {
                    PopUp.Show( "Saving failed: file \"" + path + "\" was NOT opened: " + e.message, PopUp.POP_UP_ERROR );
                    return;
                }
                fileStream.writeUTFBytes( jsonString );
                fileStream.close();
                
                Cc.info("JSON successfully written to:", path);
            } catch ( e : Error ) {
                Cc.error( "Failed to write JSON:", e.message, "Error ID:", e.errorID, "Stack Trace:", e.getStackTrace() );
                PopUp.Show( "Failed to write JSON: " + e.message, PopUp.POP_UP_ERROR );
            }
        }
        public static function read( path : String ) : ProjectData {
            try {
                var file:File = new File(path);
                if ( ! file.exists ) {
                    Cc.error( "File does not exist:", path );
                    return null;
                }

                var fileStream:FileStream = new FileStream();
                try
                {
                    fileStream.open( file, FileMode.READ );
                }
                catch ( e : Error )
                {
                    PopUp.Show( "Saving failed: file \"" + path + "\" was NOT opened: " + e.message, PopUp.POP_UP_ERROR );
                    return null;
                }
                var jsonString : String = fileStream.readUTFBytes( fileStream.bytesAvailable );
                fileStream.close();

                var jsonObject : Object = JSON.parse( jsonString );
                return json_to_project( jsonObject );
            } catch (e:Error) {
                Cc.error("Failed to read JSON:", e.message);
            }
            return null;
        }
        public static function project_to_json( p : ProjectData ) : Object {
            var complexes : Vector.< ComplexTemplate > = new Vector.< ComplexTemplate >();
            var compounds : Vector.< CompoundTemplate > = new Vector.< CompoundTemplate >();
            for each ( var o : ObjectTemplate in p._objects ) {
                if ( o is CompoundTemplate ) {
                    compounds.push( o );
                }
                else {
                    complexes.push( o );
                }
            }

            return {
                version: 1, // Increment this when making breaking changes
                tileSize : p._tileSize,
                resources : map( p._resources.concat(), function( r : Resource ) : Object { return write_resource( r ); } ),
                complexes : map( complexes.concat(), function( c : ComplexTemplate ) : Object { return write_complex( c ); } ),
                compounds : map( compounds.concat(), function( c : CompoundTemplate ) : Object { return write_compound( c ); } ),
                maps : map( p._maps.concat(), function( m : Map ) : Object { return write_map( m ); } ),
                layers : map( p._layers.concat(), function( l : Layer ) : Object { return write_layer( l ); } ),
                generationFolder : p._generationFolder,
                regions : map( p._regions.concat(), function( r : Region ) : Object { return write_region( r ); } ),
                unitProperties : map( p._unitProperties.concat(), function( u : UnitProperties ) : Object { return write_up( u ); } ),
                slippingValue : p._slippingValue,
                sourcesDirectory : p._sourcesDirectory,
                throughAlpha : p._throughAlpha,
                preferences : {
                    movingWay : p._preferences._movingWay,
                    spawning : p._preferences._spawning
                },
                animationProperties : map( p._animationProperties.concat(), function( a : AnimationProperties ) : Object { return write_ap( a ); } ),
                performPerPixelAnimationsCheck : p._performPerPixelAnimationsCheck
            };
        }
        public static function map( v : Vector.<*>, f : Function ) : Array {
            var r : Array = [];
            for each ( var item : * in v ) {
                r.push( f( item ) );
            }
            return r;
        }
        private static function write_map( m : Map ) : Object {
            return {
                name : m._name,
                instances : map( m._instances.concat(), function( i : ObjectInstance ) : Object {
                    return {
                        template : i._template._name,
                        tileCoords : {
                            x : i._tileCoords.x,
                            y : i._tileCoords.y
                        }
                    }
                }),
                right : m._right,
                down : m._down,
                drawBorder : m._drawBorder,
                drawGrid : m._drawGrid,
                clampToTiles : m._clampToTiles,
                unitsSpeed : m._unitsSpeed
            };
        }
        private static function write_resource( r : Resource ) : Object {
            return {
                path : r._path
            }
        }
        private static function write_complex( c : ComplexTemplate ) : Object {
            return {
                name : c._name,
                singleResource : {
                    resourcePath : c._singleResource._resourcePath,
                    name : c._singleResource._name
                },
                disp : {
                    x : c._disp.x,
                    y : c._disp.y
                },
                regions : map( c._regions.concat(), function( r : RegionWithinComplex ) : Object { return {
                    region : r._region._name,
                    tiles : map( r._tiles.concat(), function( t : Point ) : Object { return {
                        x : t.x,
                        y : t.y
                    } } )
                }; } ),
                layer : c._layer ? c._layer._name : null,
                center : {
                    x : c._center.x,
                    y : c._center.y
                },
                interactive : c._interactive
            };
        }
        private static function write_compound( c : CompoundTemplate ) : Object {
            return {
                name : c._name,
                consisting : map( c._consisting.concat(), function( w : ComplexWithinCompound ) : Object { return {
                    complex : w._complex._name,
                    tileDispX : w._tileDispX,
                    tileDispY : w._tileDispY
                } } )
            };
        }
        private static function write_layer( l : Layer ) : Object {
            return {
                name : l._name,
                units : l._units,
                gridHolder : l._gridHolder,
                visible : l._visible,
                selectable : l._selectable
            }
        }
        private static function write_region( r : Region ) : Object {
            return {
                name : r._name,
                type : r._type,
                color : r._color
            }
        }
        private static function write_up( u : UnitProperties ) : Object {
            return {
                unit : u._unit,
                surfaces : map( u._surfaces.concat(), function( s : Region ) : String { return s._name; } ),
                refusedDirections : u._refusedDirections.concat()
            }
        }
        private static function write_ap( a : AnimationProperties ) : Object {
            return {
                editorsPath : a._editorsPath,
                animationName : a._animationName,
                eachFrame : a._eachFrame
            }
        }

        public static function json_to_project( json : Object ) : ProjectData {
            var p : ProjectData = new ProjectData();

            if ( json.version != 1 ) {
                Cc.error( "Warning: Unsupported project data version:", json.version );
                PopUp.Show( "Failed to open project file: version " + json.version + " is NOT supported by this editor.", PopUp.POP_UP_ERROR );
            }

            p._tileSize = json.tileSize;

            for each ( var r : Object in json.resources ) {
                var resource : Resource = new Resource();
                resource._path = r.path;
                p._resources.push( resource );
            }

            for each ( var r in json.regions ) {
                var region : Region = new Region();
                region._name = r.name;
                region._type = r.type;
                region._color = r.color;
                p._regions.push( region );
            }
            function resolve_region( name : String ) : Region {
                for each ( var r : Region in p._regions ) {
                    if ( r._name == name ) {
                        return r;
                    }
                }
                return null;
            };

            for each ( var l in json.layers ) {
                var layer : Layer = new Layer();
                layer._name = l.name;
                layer._units = l.units;
                layer._gridHolder = l.gridHolder;
                layer._visible = l.visible;
                layer._selectable = l.selectable;
                p._layers.push( layer );
            }
            function resolve_layer( name : String ) : Layer {
                for each ( var l : Layer in p._layers ) {
                    if ( l._name == name ) {
                        return l;
                    }
                }
                return null;
            };

            for each ( var o : Object in json.complexes ) {
                var complex : ComplexTemplate = new ComplexTemplate();
                complex._name = o.name;
                complex._singleResource = new SingleResource();
                complex._singleResource._resourcePath = o.singleResource.resourcePath;
                complex._singleResource._name = o.singleResource.name;
                complex._disp = new Point( o.disp.x, o.disp.y );
                for each ( var r : Object in o.regions ) {
                    var w : RegionWithinComplex = new RegionWithinComplex();
                    w._region = resolve_region( r.region );
                    for each ( var t : Object in r.tiles ) {
                        w._tiles.push( new Point( t.x, t.y ) );
                    }
                    complex._regions.push( w );
                }
                complex._layer = o.layer ? resolve_layer( o.layer ) : null;
                complex._center = new Point( o.center.x, o.center.y );
                complex._interactive = o.interactive;
                p._objects.push( complex );
            }
            function resolve_template( name : String ) : ObjectTemplate {
                for each ( var c : ObjectTemplate in p._objects ) {
                    if ( c._name == name ) {
                        return c;
                    }
                }
                throw new Error( "template was NOT resolved: " + name );
            };

            for each ( var o : Object in json.compounds ) {
                var compound : CompoundTemplate = new CompoundTemplate();
                compound._name = o.name;
                for each ( var rwc : Object in o.consisting ) {
                    var complexWithinCompound : ComplexWithinCompound = new ComplexWithinCompound();
                    complexWithinCompound._complex = resolve_template( rwc.complex ) as ComplexTemplate;
                    complexWithinCompound._tileDispX = rwc.tileDispX;
                    complexWithinCompound._tileDispY = rwc.tileDispY;
                    compound._consisting.push( complexWithinCompound );
                }
                if ( compound._consisting.length < 1 ) {
                    throw new Error( "empty compound: " + compound._name );
                }
                p._objects.push( compound );
            }

            for each ( var m : Object in json.maps ) {
                var map : Map = new Map();
                map._name = m.name;
                for each ( var i : Object in m.instances ) {
                    var instance : ObjectInstance = new ObjectInstance();
                    instance._template = resolve_template( i.template );
                    instance._tileCoords = new Point( i.tileCoords.x, i.tileCoords.y );
                    map._instances.push( instance );
                }
                map._right = m.right;
                map._down = m.down;
                map._drawBorder = m.drawBorder;
                map._drawGrid = m.drawGrid;
                map._clampToTiles = m.clampToTiles;
                map._unitsSpeed = m.unitsSpeed;
                p._maps.push( map );
            }

            for each ( var u : Object in json.unitProperties ) {
                var unitProperties : UnitProperties = new UnitProperties();
                unitProperties._unit = u.unit;
                for each ( var s : String in u.surfaces ) {
                    unitProperties._surfaces.push( resolve_region( s ) );
                }
                for each ( var d : int in u.refusedDirections ) {
                    unitProperties._refusedDirections.push( d );
                }
                p._unitProperties.push( unitProperties );
            }

            p._preferences._movingWay = json.preferences.movingWay;
            p._preferences._spawning = json.preferences.spawning;

            for each ( var a : Object in json.animationProperties ) {
                var animationProperties : AnimationProperties = new AnimationProperties();
                animationProperties._editorsPath = a.editorsPath;
                animationProperties._animationName = a.animationName;
                animationProperties._eachFrame = a.eachFrame;
                p._animationProperties.push( animationProperties );
            }

            p._generationFolder = json.generationFolder;
            p._slippingValue = json.slippingValue;
            p._sourcesDirectory = json.sourcesDirectory;
            p._throughAlpha = json.throughAlpha;
            p._performPerPixelAnimationsCheck = json.performPerPixelAnimationsCheck;

            return p;
        }
    }
}