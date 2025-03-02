///@cond
/**
 * Copyright (C) 2011 by CJ Cenizal
 * Use this code to do whatever you want, just don't claim it as your own, because I wrote it. Not you!
 * Adapted by SlavMFM@gmail.com for engine-like usage. Cheers!
 */
package blisc.core
{
	import blisc.instances.BliscComplexWithinCompound;
	import blisc.instances.BliscCompound;
	import blisc.instances.BliscIsometric;
	import blisc.instances.BliscUnit;
	import blisc.pathfinding.AStar;
	import blisc.templates.BliscLayerTemplate;
	import com.junkbyte.console.Cc;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import utils.Utils;
	import view.View;
	
	CONFIG::stage3d
	{
		import flash.display3D.Context3D;
		import flash.display3D.Context3DRenderMode;
		import flash.display.Stage3D;
		import com.adobe.utils.AGALMiniAssembler;
		import flash.display3D.Program3D;
		import flash.display3D.VertexBuffer3D;
		import flash.geom.Matrix3D;
		import flash.display3D.Context3DProgramType;
	}
	
	///@endcond
	
	/** Draws specified isometric objects and resolves mouse events.*/
	public class Blisc extends View
	{
		// Screen coords.
		private var _screenCoordOffsetX : Number = 0;
		private var _screenCoordOffsetY : Number = 0;
		
		// Bounds.
		/** How far visible area is stretched to right and left around 0;0 center.*/
		private var _boundsRight : int = 0;
		/** How far visible area is stretched to up and down around 0;0 center.*/
		private var _boundsDown : int = 0;
		/** Min and max values camera's focus allowed to reach.*/
		private var _boundsMaxX : Number = 0;
		private var _boundsMinX : Number = 0;
		private var _boundsMaxY : Number = 0;
		private var _boundsMinY : Number = 0;
		
		// Validation.
		private var _cameraSizeIsDirty : Boolean = false;
		private var _zoomIsDirty : Boolean = false;
		
		CONFIG::stage3d == false
		{
			/** Viewport.*/
			public var _canvas : Bitmap;
		}
		public var _layers : BliscLayers;
		
		// Camera.
		private var _baseViewPortWidth : int = 0;
		private var _baseViewPortHeight : int = 0;
		private var _viewPortWidth : int = 0;
		private var _viewPortHeight : int = 0;
		/** Camera center (stretches to right, left, up and down around it).*/
		private var _cameraFocusX : Number = 0;
		private var _cameraFocusY : Number = 0;
		/** Upper left corner of the camera.*/
		private var _cameraOffsetX : Number = 0;
		private var _cameraOffsetY : Number = 0;
		private var _zoom : Number = 1;
		
		private var _isMouseDown : Boolean = false;
		
		// Dragging.
		private var _prevX : int = 0;
		private var _prevY : int = 0;
		
		/** Object, upon which mouse pointer is currently hovering.*/
		public var _overOpaqueData : * = null;
		
		/** How much pixels mouse pointer can move while holding left mouse down and still issuing "mouse click" event.*/
		private var _dragThreshold : Number;
		
		/** How much pixels mouse moved being clicked.*/
		private var _draggingMove : Number;
		
		private var _tileSide : Number;
		
		public var _aStar : AStar;
		
		private var _tempOver : Vector.< * > = new Vector.< * >;
		private var _tempAlpha : Vector.< BliscDisplayObject > = new Vector.< BliscDisplayObject >;
		
		public static const SELECTION_FIRST : int = 1;
		public static const SELECTION_LAST : int = 2;
		public var _selection : int;
		
		public var _throughAlpha : int;
		
		private var _globalMouseX : Number;
		private var _globalMouseY : Number;
		private var _mouseChanged : Boolean = false;
		
		
		public static const LAYER_DEFAULT : String = "default";
		
		/** True if viewport must be filled with white color before drawing.*/
		public var _fill : Boolean
		
		/** Objects single-linked list consisting of drawn once to speed up mouse selection function.*/
		public var _drawn : BliscDisplayObject = null;
		public var _drawnLast : BliscDisplayObject = null;
		
		CONFIG::stage3d
		{
			public var _batch : BliscBatch;
			
			public var _invalidatedPos : Boolean = true;
			
			/** Finding the amount of objects which will be drawn in a mediate amount of time.*/
			public var _limit : int;
			public static const LIMIT : int = 500;
		}
		
		
		/** 
		\param viewport Where everything must be drawn.
		\param dragThreshold How much pixels mouse pointer can move while holding left mouse down and still issuing "mouse click" event.
		\param boundsRight How far visible area is stretched to right and left around 0;0 center.
		\param boundsDown How far visible area is stretched to up and down around 0;0 center.
		\param tileSide Distance from tile's north to east.
		\param selection Which object must be chosen as selected one amongst all objects under mouse pointer.
		\param throughAlpha Alpha value to set to hiding objects which hides selected object.
		\param onCreated function() : void Called if specified when everything is properly initialiazed.
		.*/
		public function Blisc(
			viewport : DisplayObjectContainer,
			mouseHandler : Function,
			cameraWidth : int,
			cameraHeight : int,
			boundsRight : int,
			boundsDown : int,
			dragThreshold : Number,
			tileSide : Number,
			aStar : AStar,
			selection : int = SELECTION_FIRST,
			throughAlpha : int = 100,
			fill : Boolean = true,
			batch : BliscBatch = null
		)
		{
			super( viewport, mouseHandler );
			
			_baseViewPortWidth = _viewPortWidth = cameraWidth;
			_baseViewPortHeight = _viewPortHeight = cameraHeight;
			_boundsRight = boundsRight;
			_boundsDown = boundsDown;
			_dragThreshold = dragThreshold;
			_tileSide = tileSide;
			_selection = selection;
			_throughAlpha = throughAlpha;
			_fill = fill;
			
			_layers = new BliscLayers( this );
			
			if ( CONFIG::stage3d == false )
			{
				_canvas = new Bitmap( new BitmapData( _baseViewPortWidth, _baseViewPortHeight ) );
				_viewport.addChild( _canvas );
			}
			
			UpdateBounds();
			UpdateCameraOffset();
			
			_aStar = aStar;
			
			if ( CONFIG::stage3d )
			{
				_batch = batch;
			}
		}
		
		override public function Destroy() : void
		{
			_layers.Destroy();
			
			if ( CONFIG::stage3d == false )
			{
				if ( _canvas != null )
				{
					Utils.Hide( _canvas );
					if ( _canvas.bitmapData != null )
					{
						_canvas.bitmapData.dispose();
						_canvas.bitmapData = null;
					}
				}
			}
		}
		
		public function OnMouseDown( x : Number, y : Number ) : void
		{
			_isMouseDown = true;
			_prevX = x;
			_prevY = y;
			
			_draggingMove = 0;
		}
		
		public function OnMouseMove( x : Number, y : Number ) : void
		{
			if ( _isMouseDown )
			{
				const deltaX : Number = _prevX - x;
				const deltaY : Number = _prevY - y;
				
				MoveCamera( deltaX, deltaY );
				_prevX = x;
				_prevY = y;
				
				_draggingMove += Math.sqrt( deltaX * deltaX + deltaY * deltaY );
			}
			else
			{
				_globalMouseX = x + _cameraOffsetX;
				_globalMouseY = y + _cameraOffsetY;
				_mouseChanged = true;
			}
		}
		
		public function OnMouseUp( x : Number, y : Number ) : void
		{
			if ( _draggingMove <= _dragThreshold )
			{
				if ( _overOpaqueData == null )
				{
					_mouseHandler( View.MOUSE_MISS, new Point( x, y ) );
				}
				else
				{
					_mouseHandler( View.MOUSE_CLICK, _overOpaqueData );
				}
			}
			
			_isMouseDown = false;
		}
		
		//===================================
		//		Objects.
		//===================================
		
		public function AddObject( object : BliscIsometric ) : void
		{
			object._blisc = this;
			
			
			var compound : BliscCompound = object as BliscCompound;
			if ( compound != null )
			{
				for each ( var complex : BliscComplexWithinCompound in compound._complexes )
				{
					AddBdo( complex._complex._bdo );
				}
			}
			else
			{
				var unit : BliscUnit = object as BliscUnit;
				
				AddBdo( unit._bdo );
			}
		}
		
		private function AddBdo( bdo : BliscDisplayObject ) : void
		{
			_layers.AddObject( bdo, bdo._layerId );
		}
		
		public function AddLayer( template : BliscLayerTemplate, visible : Boolean = true ) : void
		{
			_layers.Add( template, visible );
		}
		
		//===================================
		//		Camera controls.
		//===================================
		
		/** Move camera from current position by specified planar units.*/
		public function MoveCamera( dx : Number, dy : Number ) : void
		{
			_cameraFocusX += dx / _zoom;
			_cameraFocusY += dy / _zoom;
			
			ClampCameraToBounds();
			UpdateCameraOffset();
		}
		
		/** Move camera's center to specified position.*/
		public function MoveCameraTo( x : Number, y : Number ) : void
		{
			_cameraFocusX = x;
			_cameraFocusY = y;
			
			ClampCameraToBounds();
			UpdateCameraOffset();
		}
		
		/** AKA viewport size.*/
		public function SetCameraSize( w : int, h : int ) : void
		{
			_baseViewPortWidth = w;
			_baseViewPortHeight = h;
			_cameraSizeIsDirty = true;
		}
		
		/** Wasn't tested yet at all.*/
		public function set zoom( val : Number ) : void
		{
			if ( _zoom != val )
			{
				_zoom = val;
				_zoomIsDirty = true;
			}
		}
		
		public function get zoom() : Number
		{
			return _zoom;
		}
		
		/** X coordinate of viewport's upper left corner relative to view's center.*/
		public function get cameraOffsetX() : Number
		{
			return _cameraOffsetX;
		}
		
		/** Y coordinate of viewport's upper left corner relative to view's center.*/
		public function get cameraOffsetY() : Number
		{
			return _cameraOffsetY;
		}
		
		/** X position of camera's center (not upper left corner).*/
		public function get cameraFocusX() : Number
		{
			return _cameraFocusX;
		}
		
		/** Y position of camera's center (not upper left corner).*/
		public function get cameraFocusY() : Number
		{
			return _cameraFocusY;
		}
		
		//===================================
		//		Camera.
		//===================================
		
		private function UpdateCameraSize() : void
		{
			_viewPortWidth = _baseViewPortWidth / _zoom;
			_viewPortHeight = _baseViewPortHeight / _zoom;
			if ( _viewPortWidth < 0 )
			{
				_viewPortWidth = 1;
			}
			if ( _viewPortHeight < 0 )
			{
				_viewPortHeight = 1;
			}
			const MAX : int = 8191;
			if ( _viewPortWidth > MAX )
			{
				Cc.error( "E: Blisc.UpdateCameraSize(): width = " + _viewPortWidth + " is outbound." );
				_viewPortWidth = MAX;
			}
			if ( _viewPortHeight > MAX )
			{
				Cc.error( "E: Blisc.UpdateCameraSize(): width = " + _viewPortHeight + " is outbound." );
				_viewPortHeight = MAX;
			}
			if ( _viewPortWidth * _viewPortHeight > 16777215 )
			{
				Cc.error( "E: Blisc.UpdateCameraSize(): width * height = " + ( _viewPortWidth * _viewPortHeight ) + " is outbound." );
				_viewPortWidth = _viewPortHeight = 4095;
			}
			
			if ( CONFIG::stage3d == false )
			{
				_canvas.bitmapData.dispose();
				_canvas.bitmapData = new BitmapData( _viewPortWidth, _viewPortHeight );
			}
			
			UpdateBounds();
			ClampCameraToBounds();
			UpdateCameraOffset();
			_cameraSizeIsDirty = false;
		}
		
		private function UpdateBounds():void
		{
			if ( _viewPortWidth < _boundsRight * 2.0 )
			{
				_boundsMinX = _viewPortWidth / 2.0 - _boundsRight;
				_boundsMaxX = _boundsRight - _viewPortWidth / 2.0;
			}
			else
			{
				_boundsMinX = ( _boundsRight * 2.0 - _viewPortWidth ) * _zoom;
				_boundsMaxX = ( _viewPortWidth - _boundsRight * 2.0 ) * _zoom;
			}
			
			if ( _viewPortHeight < _boundsDown * 2.0 )
			{
				_boundsMinY = _viewPortHeight / 2.0 - _boundsDown;
				_boundsMaxY = _boundsDown - _viewPortHeight / 2.0;
			}
			else
			{
				_boundsMinY = ( _boundsDown * 2.0 - _viewPortHeight ) * _zoom;
				_boundsMaxY = ( _viewPortHeight - _boundsDown * 2.0 ) * _zoom;
			}
		}
		
		private function ClampCameraToBounds(): void
		{
			if ( _cameraFocusX < _boundsMinX )
			{
				_cameraFocusX = _boundsMinX;
			}
			else if ( _cameraFocusX > _boundsMaxX )
			{
				_cameraFocusX = _boundsMaxX;
			}
			if ( _cameraFocusY < _boundsMinY )
			{
				_cameraFocusY = _boundsMinY;
			}
			else if ( _cameraFocusY > _boundsMaxY )
			{
				_cameraFocusY = _boundsMaxY;
			}
		}
		
		private function UpdateCameraOffset() : void
		{
			_cameraOffsetX = Math.floor( _cameraFocusX - ( _viewPortWidth / 2.0 ) );
			_cameraOffsetY = Math.floor( _cameraFocusY - ( _viewPortHeight / 2.0 ) );
			
			if ( CONFIG::stage3d )
			{
				_invalidatedPos = true;
			}
		}
		
		private function UpdateZoom() : void
		{
			if ( _zoom < 0.01 )
			{
				_zoom = 0.01;
			}
			
			if ( CONFIG::stage3d == false )
			{
				_canvas.scaleX = _canvas.scaleY = _zoom;
			}
			
			_zoomIsDirty = false;
			_cameraSizeIsDirty = true;
		}
		
		//===================================
		//		Time.
		//===================================
		
		public function draw( ignoreMouse : Boolean = false ) : void
		{
			_drawn = null;
			_drawnLast = null;
			
			if ( _zoomIsDirty )
			{
				UpdateZoom();
			}
			if ( _cameraSizeIsDirty )
			{
				UpdateCameraSize();
			}
			
			//dunno if I missed something but _layers.Draw() consume +~3 ms if lock()/unlock() used while they themself do not consume any time:
			/*if ( DEBUG::profiling )
			{
				const lockGot : int = getTimer();
			}
			_canvas.bitmapData.lock();
			if ( DEBUG::profiling )
			{
				Cc.info( "E: Blisc.draw(): lock() got " + ( getTimer() - lockGot ).toString() + " ms." );
			}*/
			
			if ( CONFIG::stage3d )
			{
				_limit = 0;
				
				_batch._context3D.clear( 0.5, 0.5, 0.5 );
				
				_batch._context3D.setProgram( BliscBatch._program );
				
				_batch._context3D.setBlendFactors( Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA );
				
				_batch._context3D.setVertexBufferAt( 0, _batch._buffer, 0, Context3DVertexBufferFormat.FLOAT_2 ); //xy
				_batch._context3D.setVertexBufferAt( 1, _batch._buffer, 2, Context3DVertexBufferFormat.FLOAT_2 ); //uv
				
				//camera:
				_batch._viewMatrix.identity();
				//flip y-axis so it points down and shift origin to upper-left corner
				_batch._viewMatrix.appendTranslation(
					- _batch._stage.stageWidth / 2 - _cameraOffsetX,
					- _batch._stage.stageHeight / 2 - _cameraOffsetY,
					0
				);
				_batch._viewMatrix.appendScale( 1, -1, 1 );
				
				//projection:
				BliscBatch.ApplyOrthoProjection( _batch._orthoData, _batch._stage.stageWidth, _batch._stage.stageHeight, 0, 100 )
				_batch._orthoProjection.rawData = _batch._orthoData;
				
				//final world matrix:
				_batch._mvp.identity();
				_batch._mvp.append( _batch._viewMatrix );
				//projection
				_batch._mvp.append( _batch._orthoProjection );
			}
			else
			{
				//if to call this function 10 times it will get ~20 (17-23) ms:
				if ( _fill )
				{
					_canvas.bitmapData.fillRect( _canvas.bitmapData.rect, 0 );
				}
			}
			
			//Math.floor() to try to avoid (pixel-sized gaps):
			_layers.Draw(
				Math.floor( _cameraOffsetX ),
				Math.floor( _cameraOffsetY ),
				_cameraOffsetX + _viewPortWidth,
				_cameraOffsetY + _viewPortHeight, _zoom
			);
			
			if ( CONFIG::stage3d )
			{
				_batch._context3D.present();
				
				_invalidatedPos = false;
				
				Cc.info( "I: drawn " + _limit + " objects" );
			}
			
			//read before about lock():
			/*if ( DEBUG::profiling )
			{
				const unlockGot : int = getTimer();
			}
			_canvas.bitmapData.unlock();
			if ( DEBUG::profiling )
			{
				Cc.info( "E: Blisc.draw(): unlock() got " + ( getTimer() - unlockGot ).toString() + " ms." );
			}*/
			
			/*if ( DEBUG::profiling )
			{
				const mouseGot : int = getTimer();
			}*/
			//temporary removed for mobile version:
			/*if ( ignoreMouse == false )
			{
				SelectObjects();
			}*/
			/*if ( DEBUG::profiling )
			{
				Cc.info( "I: Blisc.draw(): mouse got " + ( getTimer() - mouseGot ).toString() + " ms." );
			}*/
		}
		
		/** Returns alpha to normal of all hidden previously as overlapping with mouse pointer.*/
		public function ReturnAlpha() : void
		{
			for each ( var bdo : BliscDisplayObject in _tempAlpha )
			{
				bdo._alpha = 255;
			}
			_tempAlpha.length = 0;
		}
		
		/** Select one or move (depending on _selection) objects, hide (using _alpha) other.*/
		private function SelectObjects() : void
		{
			ReturnAlpha();
			
			//this function consumes ~4.5 ms. In 80% cases remaining code consumes 0 ms, but sometimes up to 4 ms:
			if ( DEBUG::profiling )
			{
				const oupGot : int = getTimer();
			}
			//ObjectsUnderPoint( _globalMouseX, _globalMouseY, _tempOver, true );
			ObjectsUnderPointWithinCamera( _globalMouseX, _globalMouseY, _tempOver, true );
			if ( DEBUG::profiling )
			{
				Cc.info( "I: Blisc.SelectObjects(): objects detection got " + ( getTimer() - oupGot ).toString() + " ms." );
			}
			
			var opaqueData : * = null;
			if ( _tempOver.length > 0 )
			{
				if ( _selection == SELECTION_FIRST )
				{
					opaqueData = _tempOver[ 0 ];
				}
				else if ( _selection == SELECTION_LAST )
				{
					opaqueData = _tempOver[ _tempOver.length - 1 ];
				}
				
				//hide overlapping sprites belonging to other objects:
				if ( _selection == SELECTION_FIRST )
				{
					for ( var hiding : int = 0; hiding < _tempAlpha.length; ++hiding )
					{
						var hidingBdo : BliscDisplayObject = _tempAlpha[ hiding ];
						if ( hidingBdo._opaqueData == opaqueData )
						{
							continue;
						}
						hidingBdo._alpha = _throughAlpha;
					}
				}
			}
			
			if ( opaqueData == null )
			{
				if ( _overOpaqueData != null )
				{
					_mouseHandler( View.MOUSE_OUT, _overOpaqueData );
					_overOpaqueData = null;
				}
			}
			else
			{
				var objectChanged : Boolean = false;
				
				if ( opaqueData != _overOpaqueData )
				{
					objectChanged = true;
					
					if ( _overOpaqueData != null )
					{
						_mouseHandler( View.MOUSE_OUT, _overOpaqueData );
					}
					
					_overOpaqueData = opaqueData;
					_mouseHandler( View.MOUSE_OVER, opaqueData );
				}
				
				if ( objectChanged || _mouseChanged )
				{
					_mouseHandler( View.MOUSE_HOVER, opaqueData );
				}
			}
			
			_mouseChanged = false;
		}
		
		//===================================
		//		Space.
		//===================================
		
		public function ScreenToIso( x : Number, y : Number, isoToFill : Point ) : Point
		{
			x = x / _zoom + _cameraOffsetX;
			y = y / _zoom + _cameraOffsetY;
			/*isoToFill.x = y + x / 2.0;
			isoToFill.y = y - x / 2.0;*/
			return Utils.ToIso( x, y, isoToFill );
		}
		
		public function IsoToDisplay( x : Number, y : Number, toFill : Point ) : Point
		{
			IsoToFlat( x, y, toFill );
			toFill.x *= _zoom;
			toFill.y *= _zoom;
			//it's really really really strange, but _viewport.width CHANGES each frame during 0.5-1.0 seconds after mouse move when hovering positioning object next to camera's border (!!!), that's why this function returns slightly different coordinates for 0.5-1.0 seconds after mouse move:
			toFill.x += _baseViewPortWidth / 2.0 - _cameraFocusX * _zoom;
			toFill.y += _baseViewPortHeight / 2.0 - _cameraFocusY * _zoom;
			return toFill;
		}
		
		public function IsoToFlat( x : Number, y : Number, flatToFill : Point ) : Point
		{
			/*flatToFill.x = x - y;
			flatToFill.y = ( x + y ) / 2.0;*/
			return Utils.FromIso( x, y, flatToFill );
		}
		
		public function get tileSide() : Number
		{
			return _tileSide;
		}
		
		//===================================
		//		Utils.
		//===================================
		
		public function ObjectsUnderPointWithinCamera( x : Number, y : Number, toFill : Vector.< * > = null, alpha : Boolean = false, force : Boolean = false, ignoreInvisibility : Boolean = false ) : Vector.< * >
		{
			x /= zoom;
			y /= zoom;
			
			if ( toFill == null )
			{
				toFill = new Vector.< * >;
			}
			else
			{
				toFill.length = 0;
			}
			
			for ( var bdo : BliscDisplayObject = _drawn; bdo != null; bdo = bdo._drawnNext )
			{
				if ( bdo._selectable == false )
				{
					continue;
				}
				
				if ( force == false && bdo._layer._template._selectable == false )
				{
					continue;
				}
				
				if ( bdo._complex != null && bdo._complex._template._interactive == false )
				{
					continue;
				}
				
				const rX : Number = x - bdo._roundGlobal.x;
				const rY : Number = y - bdo._roundGlobal.y;
				
				if ( 
					rX < 0 ||
					rY < 0 ||
					rX > bdo._sprite._originalWidth ||
					rY > bdo._sprite._originalHeight
				)
				{
					continue;
				}
				
				if ( bdo._sprite._source.getPixel32( rX, rY ) == 0 )
				{
					continue;
				}
				
				//here we know mouse is over some opaque image's pixel...
				
				if ( alpha )
				{
					_tempAlpha.push( bdo );
				}
				
				var faced : Boolean = false;
				for each ( var facedOD : * in toFill )
				{
					if ( facedOD == bdo._opaqueData )
					{
						faced = true;
						break;
					}
				}
				if ( faced == false )
				{
					toFill.push( bdo._opaqueData );
				}
			}
			
			return toFill;
		}
		
		/** Find all objects (their opaque data) under specified global point (indepentently of camera position) in order of displaying.
		Each object will be returned only once even if it was hit twice.
		\param x Global planar position.
		\param y Global planar position.
		\param toFill Specify array to fill with hit objects or null if new will be created and returned.
		\param alpha true if _tempAlpha array need to be filled with BliscDisplayObjects.
		\param force true if _selectable layer's field must be ignored.
		\param ignoreInvisibility True if invisible layers should be processed as well.
		*/
		public function ObjectsUnderPoint( x : Number, y : Number, toFill : Vector.< * > = null, alpha : Boolean = false, force : Boolean = false, ignoreInvisibility : Boolean = false ) : Vector.< * >
		{
			x /= zoom;
			y /= zoom;
			
			if ( toFill == null )
			{
				toFill = new Vector.< * >;
			}
			else
			{
				toFill.length = 0;
			}
			
			for ( var layerIndex : int = 0; layerIndex < _layers._layers.length; ++layerIndex )
			{
				var layer : BliscLayer = _layers._layers[ layerIndex ];
				
				if ( force == false && layer._template._selectable == false )
				{
					continue;
				}
				
				if ( ignoreInvisibility == false && layer._visible == false )
				{
					continue;
				}
				
				for ( var objectIndex : int = 0; objectIndex < layer._objects.length; ++objectIndex )
				{
					var bdo : BliscDisplayObject = layer._objects[ objectIndex ];
					
					if ( bdo._sprite == null )
					{
						continue;
					}
					
					if ( bdo._selectable == false )
					{
						continue;
					}
					
					if ( bdo._alpha <= 0 )
					{
						continue;
					}
					
					if ( bdo._complex != null && bdo._complex._template._interactive == false )
					{
						continue;
					}
					
					const rX : Number = x - bdo._roundGlobal.x;
					const rY : Number = y - bdo._roundGlobal.y;
					
					if ( 
						rX < 0 ||
						rY < 0 ||
						rX > bdo._sprite._originalWidth ||
						rY > bdo._sprite._originalHeight
					)
					{
						continue;
					}
					
					if ( bdo._sprite._source.getPixel32( rX, rY ) == 0 )
					{
						continue;
					}
					
					//here we know mouse is over some opaque image's pixel...
					
					if ( alpha )
					{
						_tempAlpha.push( bdo );
					}
					
					var faced : Boolean = false;
					for each ( var facedOD : * in toFill )
					{
						if ( facedOD == bdo._opaqueData )
						{
							faced = true;
							break;
						}
					}
					if ( faced == false )
					{
						toFill.push( bdo._opaqueData );
					}
				}
			}
			
			return toFill;
		}
		
		public function Out() : void
		{
			if ( _overOpaqueData != null )
			{
				_mouseHandler( View.MOUSE_OUT, _overOpaqueData );
				_overOpaqueData = null;
			}
		}
		
		/** Reset current mouse state (stop dragging process if there was some).*/
		public function ForgetMouse() : void
		{
			_isMouseDown = false;
		}
		
		public function get dragging() : Boolean
		{
			return _isMouseDown;
		}
	}
}



