///@cond
package  
{
	import com.junkbyte.console.Cc;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import list_items.CompoundListItem;
	import list_items.LayerListItem;
	import list_items.MapListItem;
	import list_items.ResourceListItem;
	import list_items.TemplateListItem;
	import list_items.UnitListItem;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.rpc.soap.types.MapType;
	import project_data.ComplexTemplate;
	import project_data.ComplexWithinCompound;
	import project_data.CompoundTemplate;
	import project_data.Layer;
	import project_data.Map;
	import project_data.ObjectInstance;
	import project_data.ObjectTemplate;
	import project_data.ProjectData;
	import project_data.Resource;
	import project_data.SingleResource;
	import ru.etcs.utils.getDefinitionNames;
	import utils.Utils;
	
	///@endcond
	
	/** Where everything (templates, locations, animations...) is stored.*/
	public class Project
	{
		public var _data:ProjectData = new ProjectData;
		
		
		public var _main:Main;
		
		private var _loadingResourceIndex:int;
		
		
		public function Project( main:Main )
		{
			//to save and load project using AMF:
			registerClassAlias( "project_data.ProjectData", ProjectData );
			registerClassAlias( "project_data.ComplexTemplate", ComplexTemplate );
			registerClassAlias( "project_data.ComplexWithinCompound", ComplexWithinCompound );
			registerClassAlias( "project_data.CompoundTemplate", CompoundTemplate );
			registerClassAlias( "project_data.Layer", Layer );
			registerClassAlias( "project_data.Map", Map );
			registerClassAlias( "project_data.ObjectInstance", ObjectInstance );
			registerClassAlias( "project_data.ObjectTemplate", ObjectTemplate );
			registerClassAlias( "project_data.Resource", Resource );
			registerClassAlias( "project_data.SingleResource", SingleResource );
			registerClassAlias( "flash.geom.Point", Point );
			
			_main = main;
		}
		
		/** Initialize using specified data.
		\param onResult function( errorText:String ): void where errorText is non-null value when anything gone wrong.
		*/
		public function Accept( data:ByteArray, onResult:Function ): void
		{
			try
			{
				Accept_Unsafe( data );
			}
			catch ( e:Error )
			{
				onResult( e.message );
			}
			
			//graphical resources:
			_loadingResourceIndex = 0;
			_main._resources_list_data_provider.removeAll();
			_main._units_list_data_provider.removeAll();
			LoadNextResource( function( errorText:String ): void
			{
				if ( errorText == null )
				{
					LoadTemplates();
					
					LoadLayers();
					
					LoadMaps();
					
					onResult( null );
				}
				else
				{
					onResult( errorText );
				}
			} );
		}
		
		private function Clear( list:IList ): void
		{
			if ( list != null )
			{
				list.removeAll();
			}
		}
		
		private function LoadTemplates(): void
		{
			_main._templates_list_data_provider.removeAll();
			_main._compounds_table.dataProvider.removeAll();
			
			for ( var i:int = 0; i < _data._objects.length; ++i )
			{
				var complex:ComplexTemplate = _data._objects[ i ] as ComplexTemplate;
				if ( complex == null )
				{
					var compound:CompoundTemplate = _data._objects[ i ] as CompoundTemplate;
					_main._compounds_table.dataProvider.addItem( new CompoundListItem( compound._name, compound ) );
				}
				else
				{
					_main._templates_list_data_provider.addItem( new TemplateListItem( complex._name, complex ) );
				}
			}
		}
		
		private function LoadLayers(): void
		{
			_main._layers_list_data_provider.removeAll();
			
			for ( var i:int = 0; i < _data._layers.length; ++i )
			{
				var layer:Layer = _data._layers[ i ];
				
				_main._layers_list_data_provider.addItem( new LayerListItem( layer._name, layer, i ) );
			}
		}
		
		private function LoadMaps(): void
		{
			_main._maps_list_data_provider.removeAll();
			
			for ( var i:int = 0; i < _data._maps.length; ++i )
			{
				var map:Map = _data._maps[ i ];
				
				_main._maps_list_data_provider.addItem( new MapListItem( map._name, map ) );
			}
		}
		
		private function LoadNextResource( onResult:Function ): void
		{
			if ( _loadingResourceIndex >= _data._resources.length )
			{
				onResult( null );
			}
			else
			{
				LoadResource( _data._resources[ _loadingResourceIndex ]._path, function( applicationDomain:ApplicationDomain, names:Array, FPS:Number ): void
				{
					_data._resources[ _loadingResourceIndex ].Init( applicationDomain, names, FPS, _main );
					
					DisplayResource( _data._resources[ _loadingResourceIndex ] );
					
					++_loadingResourceIndex;
					LoadNextResource( onResult );
				},
				function( why:String ): void
				{
					_main.PopUp( "Resource \"" + _data._resources[ _loadingResourceIndex ]._path + "\" was not loaded: " + why + ". Skipping it.", Main.POP_UP_WARNING );
					_data._resources.splice( _loadingResourceIndex, 1 );
					LoadNextResource( onResult );
				} );
			}
		}
		
		private function Accept_Unsafe( data:ByteArray ): void
		{
			_data = data.readObject() as ProjectData;
		}
		
		/** Generate data to save appropriate for future accepting.*/
		public function DataToSave(): ByteArray
		{
			//avoid saving data which cannot (and not needed) be saved:
			var temp:Array = [];
			var i:int = 0;
			var j:int = 0;
			for ( ; i < _data._resources.length; ++i )
			{
				var sr:Resource = _data._resources[ i ];
				
				temp.push( { ad: sr._applicationDomain, n: sr._names, u: sr._units, F: sr._FPS } );
				
				_data._resources[ i ]._applicationDomain = null;
				_data._resources[ i ]._names = null;
				_data._resources[ i ]._units = null;
			}
			
			var byteArray:ByteArray = new ByteArray;
			byteArray.writeObject( _data );
			
			
			for ( i = 0; i < _data._resources.length; ++i )
			{
				var lr:Resource = _data._resources[ i ];
				
				lr._applicationDomain = temp[ i ].ad;
				lr._names = temp[ i ].n;
				lr._units = temp[ i ].u;
				lr._FPS = temp[ i ].F;
			}
			
			return byteArray;
		}
		
		/** Load specified resources.
		\param path Full native path.
		\param onSuccess function( applicationDomain:ApplicationDomain, names:Array, FPS:Number ): void
		\param onFail function( why:String ): void
		*/
		private function LoadResource( path:String, onSuccess:Function, onFail:Function ): void
		{
			var loader:Loader = new Loader;
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, function( e:Event ): void
			{
				var target:LoaderInfo = e.target as LoaderInfo;
				onSuccess(
					target.applicationDomain,
					getDefinitionNames( target ),
					target.frameRate
				);
			} );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, function( ioErrorEvent:IOErrorEvent ): void
			{
				onFail( ioErrorEvent.text );
			} );
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, function( securityErrorEvent:SecurityErrorEvent ): void
			{
				onFail( securityErrorEvent.text );
			} );
			loader.load( new URLRequest( path ) );
		}
		
		public function AddResource( andDisplay:Boolean = true ): void
		{
			var thisOne:Project = this;
			
			var browseToResource:File = new File;
			browseToResource.addEventListener( Event.SELECT, function( ... args ): void
			{
				var path:String = new File( File.applicationDirectory.nativePath ).getRelativePath( new File( browseToResource.nativePath ), true );
				
				LoadResource( path, function( applicationDomain:ApplicationDomain, names:Array, FPS:Number ): void
				{
					_main.PopUp( "Resource successfully added", Main.POP_UP_INFO );
					
					var resource:Resource = new Resource;
					resource._path = path;
					resource.Init( applicationDomain, names, FPS, _main );
					
					_data._resources.push( resource );
					
					DisplayResource( resource );
					
					if ( andDisplay )
					{
						_main._resourcesPreview.Display( resource, thisOne );
					}
				},
				function( why:String ): void
				{
					_main.PopUp( "Resource adding failed: " + why, Main.POP_UP_ERROR );
				} );
			} );
			browseToResource.browse();
		}
		
		private function DisplayResource( resource:Resource ): void
		{
			_main._resources_list_data_provider.addItem( new ResourceListItem( resource._path, resource ) );
			
			for each ( var unitDesc:UnitDesc in resource._units)
			{
				_main._units_list_data_provider.addItem( new UnitListItem( unitDesc._name, unitDesc ) );
			}
		}
		
		public function AddObjectTemplate( template:ObjectTemplate ): void
		{
			_data._objects.push( template );
			
			//represent within view:
			if ( template is ComplexTemplate )
			{
				_main._templates_list_data_provider.addItem( new TemplateListItem( template._name,  template as ComplexTemplate ) );
			}
			else
			{
				_main._compounds_table.dataProvider.addItem( new CompoundListItem( template._name, template as CompoundTemplate ) );
			}
		}
		
		public function AddMap( map:Map ): void
		{
			_data._maps.push( map );
			_main._maps_list_data_provider.addItem( new MapListItem( map._name, map ) );
		}
		
		public function FindResource( path:String ): Resource
		{
			for each ( var resource:Resource in _data._resources )
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
			return _data._tileSize * Utils.TILE_SIDE;
		}
		
	}

}

