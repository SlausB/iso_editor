///@cond
package  
{
	import com.junkbyte.console.Cc;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import ie.PopUp;
	import ie.ResourceMissingWindow;
	import list_items.CompoundTableItem;
	import list_items.LayerListItem;
	import list_items.MapListItem;
	import list_items.RegionListItem;
	import list_items.ResourceListItem;
	import list_items.TemplateTableItem;
	import list_items.UnitListItem;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.managers.PopUpManager;
	import mx.rpc.soap.types.MapType;
	import project_data.*;
	import ru.etcs.utils.getDefinitionNames;
	import utils.Utils;
	
	///@endcond
	
	/** Where everything (templates, locations, animations...) is stored.*/
	public class Project
	{
		public var _data : ProjectData = new ProjectData;
		public var _project_dir : String = "./";
		
		
		public var _main : Main;
		
		private var _loadingResourceIndex : int;
		
		
		public function Project( main : Main )
		{
			_main = main;
		}
		
		/** Initialize using specified data.
		\param onResult function( errorText:String ): void where errorText is non-null value when anything gone wrong.
		*/
		public function Accept(
			project_dir : String,
			jsonString : String,
			onResult : Function
		) : void
		{
			Cc.info( "Opening project dir: ", project_dir );
			_project_dir = project_dir;
			try
			{
				Accept_Unsafe( jsonString );
				Cc.info( "Loaded project:", _data );
			}
			catch ( e:Error )
			{
				Cc.error( "Error loading project: ", e );
				onResult( e.message );
				return;
			}
			
			//graphical resources:
			_loadingResourceIndex = 0;
			_main._resources_list_data_provider.removeAll();
			_main._units_list_data_provider.removeAll();
			LoadNextResource( function( errorText : String ): void
			{
				if ( errorText == null )
				{
					ValidateResourceAbsence();
					
					LoadTemplates();
					
					LoadLayers();
					
					LoadMaps();
					
					LoadRegions();
					
					//update compounds after maps loading:
					for each ( var compoundTableItem:CompoundTableItem in ( _main._compounds_table.dataProvider as ArrayCollection ).source )
					{
						compoundTableItem.UpdateUsage( _main );
						_main._compounds_table.dataProvider.itemUpdated( compoundTableItem );
					}
					
					onResult( null );
				}
				else
				{
					onResult( errorText );
				}
			} );
		}
		
		private function ValidateResourceAbsence(): void
		{
			var missingResource : Vector.< String > = new Vector.< String >;
			var removedTemplates : Vector.< String > = new Vector.< String >;
			var affectedCompounds : Vector.< String > = new Vector.< String >;
			var affectedMaps : Vector.< String > = new Vector.< String >;
			var objects : int = 0;
			
			for ( var objectIndex : int = 0; objectIndex < _data._objects.length; ++objectIndex )
			{
				var template : ComplexTemplate = _data._objects[ objectIndex ] as ComplexTemplate;
				if ( template == null )
				{
					continue;
				}
				
				//if resource even wasn't specified earlier at all:
				if ( template._singleResource == null )
				{
					continue;
				}
				
				var resource : Resource = FindResource( template._singleResource._resourcePath );
				if ( resource != null && resource._names.indexOf( template._singleResource._name ) >= 0 )
				{
					continue;
				}
				
				//missing:
				
				missingResource.push( template._singleResource._resourcePath + " -> " + template._singleResource._name );
				
				removedTemplates.push( template._name );
				
				var templatesDependence : TemplatesDependence = ResolveTemplatesDependence( template );
				
				_main.RemoveTemplate( templatesDependence );
				//to check next object which was moved closer:
				--objectIndex;
				
				for each ( var compound : CompoundTemplate in templatesDependence._compounds )
				{
					affectedCompounds.push( compound._name );
				}
				
				for each ( var map : TemplatesMapDependence in templatesDependence._maps )
				{
					affectedMaps.push( map._map._name );
				}
				
				objects += templatesDependence._instances;
			}
			
			if ( missingResource.length > 0 )
			{
				UnifyStrings( missingResource );
				UnifyStrings( removedTemplates );
				UnifyStrings( affectedCompounds );
				UnifyStrings( affectedMaps );
				
				var resourceMissingWindow : ResourceMissingWindow = PopUpManager.createPopUp( _main, ResourceMissingWindow ) as ResourceMissingWindow;
				resourceMissingWindow.Init( missingResource, removedTemplates, affectedCompounds, affectedMaps, objects );
				PopUpManager.centerPopUp( resourceMissingWindow );
			}
		}
		
		private function UnifyStrings( what : Vector.< String > ) : void
		{
			for ( var i1:int = 0; i1 < what.length; ++i1 )
			{
				//looking for copy:
				for ( var i2 : int = i1 + 1; i2 < what.length; ++i2 )
				{
					if ( what[ i1 ] == what[ i2 ] )
					{
						what.splice( i1, 1 );
						//to check moved element too:
						i1--;
						break;
					}
				}
			}
		}
		
		private function Clear( list : IList ) : void
		{
			if ( list != null )
			{
				list.removeAll();
			}
		}
		
		private function LoadTemplates() : void
		{
			_main._templates_table.dataProvider.removeAll();
			_main._compounds_table.dataProvider.removeAll();
			
			for ( var i : int = 0; i < _data._objects.length; ++i )
			{
				var complex : ComplexTemplate = _data._objects[ i ] as ComplexTemplate;
				if ( complex == null )
				{
					var compound : CompoundTemplate = _data._objects[ i ] as CompoundTemplate;
					_main._compounds_table.dataProvider.addItem( new CompoundTableItem( compound, _main ) );
				}
				else
				{
					_main._templates_table.dataProvider.addItem( new TemplateTableItem( complex, _main ) );
				}
			}
		}
		
		private function LoadLayers() : void
		{
			_main._layers_list_data_provider.removeAll();
			
			for ( var i : int = 0; i < _data._layers.length; ++i )
			{
				var layer : Layer = _data._layers[ i ];
				
				_main._layers_list_data_provider.addItem( new LayerListItem( layer._name, layer, i ) );
			}
		}
		
		private function LoadMaps() : void
		{
			_main._maps_list_data_provider.removeAll();
			
			for ( var i : int = 0; i < _data._maps.length; ++i )
			{
				var map : Map = _data._maps[ i ];
				
				_main._maps_list_data_provider.addItem( new MapListItem( map._name, map ) );
			}
		}
		
		private function LoadRegions() : void
		{
			_main._regions_list.dataProvider.removeAll();
			
			for ( var i : int = 0; i < _data._regions.length; ++i )
			{
				var region:Region = _data._regions[ i ];
				
				_main._regions_list.dataProvider.addItem( new RegionListItem( region ) );
			}
		}
		
		private function LoadNextResource( onResult : Function ) : void
		{
			if ( _loadingResourceIndex >= _data._resources.length )
			{
				onResult( null );
			}
			else
			{
				LoadResource( _data._resources[ _loadingResourceIndex ]._path, function( applicationDomain : ApplicationDomain, names : Array, FPS : Number ) : void
				{
					_data._resources[ _loadingResourceIndex ].Init( applicationDomain, names, FPS, _main );
					
					DisplayResource( _data._resources[ _loadingResourceIndex ] );
					
					++_loadingResourceIndex;
					LoadNextResource( onResult );
				},
				function( why : String ) : void
				{
					PopUp.Show( "Resource \"" + _data._resources[ _loadingResourceIndex ]._path + "\" was not loaded: " + why + ". Skipping it.", PopUp.POP_UP_WARNING );
					_data._resources.splice( _loadingResourceIndex, 1 );
					LoadNextResource( onResult );
				} );
			}
		}
		
		private function Accept_Unsafe( jsonString : String ) : void
		{
			var jsonObject : Object = JSON.parse( jsonString );
			_data = project_data.S11n.json_to_project( jsonObject );
		}
		
		/** Load specified resources.
		\param path Full native path.
		\param onSuccess function( applicationDomain:ApplicationDomain, names:Array, FPS:Number ): void
		\param onFail function( why:String ): void
		*/
		private function LoadResource(
			path : String,
			onSuccess : Function,
			onFail : Function
		) : void
		{
			// Absolute or relative path
			var base_path : File = new File( _project_dir );
			// Resolves the relative path
			var full_path : File = base_path.resolvePath( path );
			var result_path : String = full_path.nativePath;

			Cc.info( "Loading resource:", _project_dir, "+", path, "->", result_path );
			var loader : Loader = new Loader;
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, function( e:Event ): void
			{
				var target:LoaderInfo = e.target as LoaderInfo;
				onSuccess(
					target.applicationDomain,
					getDefinitionNames( target ),
					target.frameRate
				);
			} );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, function( ioErrorEvent : IOErrorEvent ) : void
			{
				Cc.error( "Resource " + result_path + " failed to load. IO Error: " + ioErrorEvent.text );
				onFail( ioErrorEvent.text );
			} );
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, function( securityErrorEvent : SecurityErrorEvent ) : void
			{
				Cc.error( "Resource " + result_path + " failed to load. Security Error: " + securityErrorEvent.text );
				onFail( securityErrorEvent.text );
			} );
			loader.load( new URLRequest( result_path ) );
		}
		
		public function AddResource( andDisplay : Boolean = true ) : void
		{
			var thisOne : Project = this;
			
			var browseToResource : File = new File;
			browseToResource.addEventListener( Event.SELECT, function( ... args ) : void
			{
				var path : String = new File( File.applicationDirectory.nativePath ).getRelativePath( new File( browseToResource.nativePath ), true );
				
				LoadResource( path, function( applicationDomain : ApplicationDomain, names : Array, FPS : Number ) : void
				{
					PopUp.Show( "Resource successfully added", PopUp.POP_UP_INFO );
					
					var resource : Resource = new Resource;
					resource._path = path;
					resource.Init( applicationDomain, names, FPS, _main );
					
					_data._resources.push( resource );
					
					DisplayResource( resource );
					
					if ( andDisplay )
					{
						_main._resourcesPreview.Display( resource, thisOne );
					}
				},
				function( why : String ) : void
				{
					PopUp.Show( "Resource adding failed: " + why, PopUp.POP_UP_ERROR );
				} );
			} );
			browseToResource.browse();
		}
		
		private function DisplayResource( resource:Resource ): void
		{
			_main._resources_list_data_provider.addItem( new ResourceListItem( resource._path, resource ) );
			
			for each ( var unitDesc : UnitDesc in resource._units )
			{
				_main._units_list_data_provider.addItem( new UnitListItem( unitDesc ) );
			}
		}
		
		public function AddObjectTemplate( template : ObjectTemplate ) : void
		{
			_data._objects.push( template );
			
			//represent within view:
			if ( template is ComplexTemplate )
			{
				_main._templates_table.dataProvider.addItem( new TemplateTableItem( template as ComplexTemplate, _main ) );
			}
			else
			{
				_main._compounds_table.dataProvider.addItem( new CompoundTableItem( template as CompoundTemplate, _main ) );
			}
		}
		
		public function AddMap( map:Map ): void
		{
			_data._maps.push( map );
			_main._maps_list_data_provider.addItem( new MapListItem( map._name, map ) );
		}
		
		public function FindResource( path : String ) : Resource
		{
			for each ( var resource : Resource in _data._resources )
			{
				if ( resource._path == path )
				{
					return resource;
				}
			}
			return null;
		}
		
		public function get side(): Number
		{
            return _data.side;
		}
		
		public function ResolveLayerIndex( layer : Layer ): int
		{
			for ( var i:int = 0; i < _data._layers.length; ++i )
			{
				if ( layer == _data._layers[ i ] )
				{
					return i;
				}
			}
			Cc.error( "E: Project.ResolveLayerIndex(): wasn't found." );
			return 0;
		}
		
		public function ResolveTemplatesDependence( template : ComplexTemplate ) : TemplatesDependence
		{
			var result : TemplatesDependence = new TemplatesDependence( template );
			
			for each ( var objectTemplate : ObjectTemplate in _data._objects )
			{
				var compoundTemplate : CompoundTemplate = objectTemplate as CompoundTemplate;
				if ( compoundTemplate == null )
				{
					continue;
				}
				
				for each ( var complexWithinCompound : ComplexWithinCompound in compoundTemplate._consisting )
				{
					if ( complexWithinCompound._complex == template )
					{
						result._compounds.push( compoundTemplate );
						break;
					}
				}
			}
			
			for each ( var map : Map in _data._maps )
			{
				var withinThisMap : TemplatesMapDependence = null;
				
				for each ( var objectInstance : ObjectInstance in map._instances )
				{
					if ( objectInstance._template == template )
					{
						if ( withinThisMap == null )
						{
							withinThisMap = new TemplatesMapDependence( map );
						}
						
						withinThisMap._instances.push ( objectInstance );
						
						result._instances++;
					}
				}
				
				if ( withinThisMap != null )
				{
					result._maps.push( withinThisMap );
				}
			}
			
			return result;
		}
		
		public function ResolveCompoundsDependence( compound : CompoundTemplate ) : CompoundsDependence
		{
			var result : CompoundsDependence = new CompoundsDependence( compound );
			
			for each ( var map : Map in _data._maps )
			{
				var withinThisMap : CompoundsMapDependence = null;
				
				for each ( var objectInstance : ObjectInstance in map._instances )
				{
					if ( objectInstance._template == compound )
					{
						if ( withinThisMap == null )
						{
							withinThisMap = new CompoundsMapDependence( map );
						}
						
						withinThisMap._instances.push ( objectInstance );
						
						result._instances++;
					}
				}
				
				if ( withinThisMap != null )
				{
					result._maps.push( withinThisMap );
				}
			}
			
			return result;
		}
		
	}

}

