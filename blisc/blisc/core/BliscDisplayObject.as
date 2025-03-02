/**
 * Copyright (C) 2011 by CJ Cenizal
 * Use this code to do whatever you want, just don't claim it as your own, because I wrote it. Not you!
 * Adapted by SlavMFM@gmail.com for engine-like usage. Cheers!
 */
package blisc.core
{
	import blisc.instances.BliscComplex;
	import blisc.pathfinding.AStarNode;
	import blisc.templates.BliscRegion;
	import blisc.templates.BliscRegionWithinComplex;
	import com.junkbyte.console.Cc;
	import flash.display.BitmapData;
	import flash.display3D.Context3DProgramType;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.System;
	import utils.Utils;
	import view.Viewable;
	
	/** Always is animation with 1 frame when it is just single sprite.*/
	public class BliscDisplayObject implements Viewable
	{
		protected var _screenPos : Point = new Point;
		protected var _isoPos : Point = new Point;
		/** Displacement of just this BDO upon Sprite independently of other instances of that sprite.*/
		protected var _bdoDisp : Point = new Point;
		public var _width : int = 0;
		public var _height : int = 0;
		public var _alpha : int = 255;
		
		private static var _alphaData : BitmapData = new BitmapData( 100, 100 );
		private static var _alphaPoint : Point = new Point;
		
		public var _layer : BliscLayer;
		public var _layerId : String;
		
		// Sorting.
		private var _sortOffsetY : Number = 0;
		public var _sortVal : int = 0;
		
		public var _sprite : BliscSprite = null;
		/** Cache based on template.*/
		public var _centerDisp : Point = new Point( 0, 0 );
		
		public var _opaqueData : *;
		
		/** Cache.*/
		private var _destPoint : Point = new Point;
		
		public var _selectable : Boolean = true;
		
		private var _highlighten : Boolean = false;
		private var _highlightenFilter : GlowFilter = null;
		/** Displacement of whole graphics within BitmapData to get space for highlighting border.*/
		private var _highlightenMargin : int = 0;
		private var _highlightenView : BitmapData = null;
		
		public var _blisc : Blisc;
		
		/** Where object must be drawn independently on camera position.*/
		public var _global : Point = new Point;
		/** To avoid Math.round() each time _global is changed - sometimes coordinate is saved as 123.999 which cause pixel-sized gaps.*/
		public var _roundGlobal : Point = new Point;
		/** How object visually displaced around his natural coordinate. Doesn't affect occpying tiles and GetTileX/Y() and so on functions.*/
		private var _visualDisp : Point = new Point;
		
		/** Back reference to object storing this one - used, at least, for pathfinding tasks.*/
		public var _complex : BliscComplex;
		
		public var _visibility : Boolean = true;
		public var _hidden : Boolean = false;
		
		public var _children : Vector.< BliscDisplayObject > = new Vector.< BliscDisplayObject >;
		public var _parent : BliscDisplayObject = null;
		private var _icon : Boolean = false;
		
		/** Specify as true if it is static (not moving) object.*/
		public var _roundPos : Boolean = false;
		
		/** Used while drawing to form objects list which was drawn (fit into the camera) to speed up mouse selection function.*/
		public var _drawnNext : BliscDisplayObject;
		
		/** Becomes true after first adding to nodes grid to allow future removing.*/
		private var _added : Boolean = false;
		
		/** How higher object must be drawn. The same as decreasing both X and Y coordinates but doesn't change sorting order.*/
		private var _elevation : Number = 0;
		
		private var _scaleX : Number = 1.0;
		private var _scaleY : Number = 1.0;
		
		
		CONFIG::stage3d
		{
			private var _worldPos : Matrix3D = new Matrix3D;
			
			private var _invalidated : Boolean = true;
		}
		
		
		
		public function BliscDisplayObject(
			blisc : Blisc,
			opaqueData : * = null,
			bdoDisp : Point = null,
			roundPos : Boolean = true,
			icon : Boolean = false
		)
		{
			_blisc = blisc;
			_opaqueData = opaqueData;
			if ( bdoDisp == null )
			{
				_bdoDisp = new Point;
			}
			else
			{
				_bdoDisp = bdoDisp;
			}
			_roundPos = roundPos;
			_icon = icon;
			
			ResolveGlobalPos();
		}
		
		public function set complex( to : BliscComplex ) : void
		{
			_complex = to;
			
			_centerDisp.x = to._template._center.x;
			_centerDisp.y = to._template._center.y;
			ResolveSortVal();
		}
		
		public function get complex() : BliscComplex
		{
			return _complex;
		}
		
		private function ResolveSortVal() : void
		{
			_sortVal = ( ( _screenPos.y + _centerDisp.y ) << 17 ) + ( _screenPos.x + _centerDisp.x );
		}
		
		/** Call specified function for each surface or space tile which this BDO covers.
		\param acceptor function( tile : AStarNode, region : BliscRegion ) : void Called for each surface or space.
		*/
		public function ForEachAffectedTile( acceptor : Function ) : void
		{
			for each ( var region : BliscRegionWithinComplex in _complex._template._regions )
			{
				if ( region._region._type == BliscRegion.TYPE_UNDEFINED )
				{
					continue;
				}
				
				for each ( var tile : Point in region._tiles )
				{
					var found : AStarNode = _blisc._aStar.grid.GetTile(
						Math.round( ( _isoPos.x / _blisc.tileSide ) + tile.x ),
						Math.round( ( _isoPos.y / _blisc.tileSide ) + tile.y )
					);
					
					if ( found == null )
					{
						continue;
					}
					
					acceptor( found, region._region );
				}
			}
		}
		
		/** Remove restrictions from all affected tiles.*/
		private function RemoveRestrictions() : void
		{
			if ( _added == false )
			{
				return;
			}
			
			//if not a unit or child element:
			if ( _complex != null )
			{
				var thisOne : BliscDisplayObject = this;
				
				ForEachAffectedTile( function( tile : AStarNode, region : BliscRegion ) : void
				{
					tile.RemoveRestrictions( thisOne );
				} );
			}
		}
		
		private function BeforePosChange() : void
		{
			if ( _hidden )
			{
				return;
			}
			
			if ( _icon == false )
			{
				RemoveRestrictions();
			}
		}
		
		private function HandlePosChange() : void
		{
			if ( _hidden )
			{
				return;
			}
			
			_added = true;
			
			//icons has no levels:
			if ( _layer != null )
			{
				_layer._dirty = true;
			}
			
			ResolveGlobalPos();
			
			if ( _icon == false )
			{
				ResolveSortVal();
				
				if ( _complex != null )
				{
					var thisOne : BliscDisplayObject = this;
					ForEachAffectedTile( function ( tile : AStarNode, region : BliscRegion ) : void
					{
						tile.AddRestriction( thisOne, region );
					} );
				}
			}
		}
		
		private function ResolveGlobalPos() : void
		{
			_global.x = _screenPos.x + _bdoDisp.x;
			_global.y = _screenPos.y + _bdoDisp.y - _elevation;
			
			if ( _sprite != null )
			{
				_global.x += _sprite._disp.x;
				_global.y += _sprite._disp.y;
			}
			
			_global.x += _visualDisp.x;
			_global.y += _visualDisp.y;
			
			if ( _roundPos )
			{
				_roundGlobal.x = Math.round( _global.x );
				_roundGlobal.y = Math.round( _global.y );
			}
			else
			{
				_roundGlobal.x = _global.x;
				_roundGlobal.y = _global.y;
			}
			
			if ( CONFIG::stage3d )
			{
				_invalidated = true;
			}
		}
		
		/** Let object to draw himself onto result viewport canvas.
		\param cameraX X coordinate of upper left corner of the camera.
		\param cameraY Y coordinate of upper left corner of the camera.
		*/
		public function draw(
			cameraX : Number,
			cameraY : Number,
			zoom : Number,
			dispX : Number = 0,
			dispY : Number = 0,
			invalidated : Boolean = false
		) : void
		{
			if ( _sprite != null && _alpha > 0 )
			{
				if ( CONFIG::stage3d )
				{
					//_roundGlobal can be used here if picture is too blurry:
					_destPoint.x = _global.x + dispX;
					_destPoint.y = _global.y + dispY;
					
					_blisc._batch._context3D.setTextureAt( 0, _sprite._texture );
					
					if ( _blisc._invalidatedPos || _invalidated || invalidated )
					{
						_worldPos.identity();
						//don't have such:
						//_worldPos.appendRotation( _rotation, Vector3D.Z_AXIS );
						_worldPos.appendScale( _sprite._width * ( _scaleX / 2 ), _sprite._height * ( _scaleY / 2 ), 1 );
						_worldPos.appendTranslation( _sprite._width / 2 + _destPoint.x, _sprite._height / 2 + _destPoint.y, 0 );
						_worldPos.append( _blisc._batch._mvp );
						
						_invalidated = false;
					}
					
					_blisc._batch._context3D.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 0, _worldPos, true );
					
					_blisc._batch._context3D.drawTriangles( BliscBatch._indexBuffer, 0, 2 );
				}
				else
				{
					var view : BitmapData = _sprite._source;
					var rect : Rectangle = _sprite._source.rect;
					
					_destPoint.x = _roundGlobal.x - cameraX + dispX;
					_destPoint.y = _roundGlobal.y - cameraY + dispY;
					
					if ( _highlighten )
					{
						_destPoint.x -= _highlightenMargin;
						_destPoint.y -= _highlightenMargin;
						
						view = _highlightenView;
						rect = _highlightenView.rect;
					}
					
					if ( _alpha < 255 )
					{
						const alpha : uint = _alpha << 24;
						if ( rect.width > _alphaData.width || rect.height > _alphaData.height )
						{
							var temp : BitmapData = new BitmapData( Math.ceil( Math.max( rect.width, _alphaData.width ) ), Math.ceil( Math.max( rect.height, _alphaData.height ) ), true, alpha );
							_alphaData.dispose();
							_alphaData = temp;
						}
						else
						{
							_alphaData.fillRect( rect, alpha );
						}
						
						_blisc._canvas.bitmapData.copyPixels( view, rect, _destPoint, _alphaData, _alphaPoint, true );
					}
					else
					{
						_blisc._canvas.bitmapData.copyPixels( view, rect, _destPoint, null, null, true );
					}
				}
			}
			
			
			for each ( var child : BliscDisplayObject in _children )
			{
				child.draw(
					cameraX,
					cameraY,
					zoom,
					_screenPos.x,
					_screenPos.y,
					true
				);
			}
			
			if ( CONFIG::stage3d )
			{
				_blisc._limit++;
			}
		}
		
		public function Destroy() : void
		{
			RemoveRestrictions();
			
			if ( _layer != null )
			{
				_layer.remove( this );
				_layer = null;
			}
			
			_highlightenFilter = null;
			if ( _highlightenView != null )
			{
				_highlightenView.dispose();
				_highlightenView = null;
			}
			
			_blisc = null;
			
			_complex = null;
			
			RemoveFromParent();
		}
		
		public function RemoveFromParent() : void
		{
			if ( _parent != null )
			{
				_parent.RemoveChild( this );
				_parent = null;
			}
		}
		
		public function AddChild( child : BliscDisplayObject ) : void
		{
			child.RemoveFromParent();
			
			_children.push( child );
			
			child._parent = this;
		}
		
		private function RemoveChild( child : BliscDisplayObject ) : void
		{
			for ( var i : int; i < _children.length; ++i )
			{
				if ( _children[ i ] == child )
				{
					_children.splice( i, 1 );
					break;
				}
			}
		}
		
		//===================================
		//		Accessors.
		//===================================
		
		public function set layer( layer : BliscLayer ) : void
		{
			_layer = layer;
			_layerId = layer.id;
		}
		
		public function SetIsoX( val:Number ): void
		{
			if ( _isoPos.x == val )
			{
				return;
			}
			
			BeforePosChange();
			_isoPos.x = val;
			ApplyIsoPos();
		}
		
		public function SetIsoY( val:Number ) :void
		{
			if ( _isoPos.y == val )
			{
				return;
			}
			
			BeforePosChange();
			_isoPos.y = val;
			ApplyIsoPos();
		}
		
		public function SetIsoXY( x : Number, y : Number ) : void
		{
			if ( _isoPos.x == x && _isoPos.y == y && _added == true )
			{
				return;
			}
			
			BeforePosChange();
			_isoPos.x = x;
			_isoPos.y = y;
			ApplyIsoPos();
		}
		
		private function ApplyIsoPos() : void
		{
			Utils.FromIso( _isoPos.x, _isoPos.y, _screenPos );
			HandlePosChange();
		}
		
		public function GetIsoX() : Number
		{
			return _isoPos.x;
		}
		
		public function GetIsoY() : Number
		{
			return _isoPos.y;
		}
		
		public function SetX( val : Number ) : void
		{
			if ( _screenPos.x == val )
			{
				return;
			}
			
			BeforePosChange();
			_screenPos.x = val;
			ApplyScreenPos();
		}
		
		public function SetY( val:Number ):void
		{
			if ( _screenPos.y == val )
			{
				return;
			}
			
			BeforePosChange();
			_screenPos.y = val;
			ApplyScreenPos();
		}
		
		public function SetXY( x : Number, y : Number ) : void
		{
			if ( _screenPos.x == x && _screenPos.y == y && _added == true )
			{
				return;
			}
			
			BeforePosChange();
			_screenPos.x = x;
			_screenPos.y = y;
			ApplyScreenPos();
		}
		
		private function ApplyScreenPos() : void
		{
			_blisc.ScreenToIso( _screenPos.x, _screenPos.y, _isoPos );
			HandlePosChange();
		}
		
		public function GetX() : Number
		{
			return _screenPos.x;
		}
		
		public function GetY() : Number
		{
			return _screenPos.y;
		}
		
		public function SetElevation( to : Number ) : void
		{
			_elevation = to;
			ResolveGlobalPos();
		}
		
		public function GetElevation() : Number
		{
			return _elevation;
		}
		
		public function Replicate( what : BliscSprite ) : void
		{
			if ( what == _sprite )
			{
				return;
			}
			
			_sprite = what;
			
			_width = _sprite._originalWidth;
			_height = _sprite._originalHeight;
			
			if ( _highlighten )
			{
				Highlight( _highlightenFilter );
			}
			
			ResolveGlobalPos();
		}
		
		public function SetSelectable( toWhat : Boolean ) : void
		{
			_selectable = toWhat;
		}
		
		public function GetSelectable() : Boolean
		{
			return _selectable;
		}
		
		public function SetTileX( x:Number ): void
		{
			SetIsoX( x * _blisc.tileSide );
		}
		
		public function SetTileY( y:Number ): void
		{
			SetIsoY( y * _blisc.tileSide );
		}
		
		public function SetTileXY( x : Number, y : Number ) : void
		{
			SetIsoXY( x * _blisc.tileSide, y * _blisc.tileSide );
		}
		
		public function GetTileX() : Number
		{
			return GetIsoX() / _blisc.tileSide;
		}
		
		public function GetTileY() : Number
		{
			return GetIsoY() / _blisc.tileSide;
		}
		
		/** Draw border around an object. Passed glowFilter will be used earlier on some conditions, so do not modify it.*/
		public function Highlight( glowFilter : GlowFilter ) : void
		{
			for each ( var child : BliscDisplayObject in _children )
			{
				child.Highlight( glowFilter );
			}
			
			
			_highlighten = true;
			_highlightenFilter = glowFilter;
			if ( _sprite == null )
			{
				return;
			}
			
			_highlightenMargin = glowFilter.inner ? 0 : Math.max( glowFilter.blurX, glowFilter.blurY );
			
			if ( _highlightenView != null )
			{
				_highlightenView.dispose();
			}
			
			_highlightenView = new BitmapData( _sprite._source.rect.width + _highlightenMargin * 2.0, _sprite._source.rect.height + _highlightenMargin * 2.0, true, 0 );
			_highlightenView.copyPixels( _sprite._source, _sprite._source.rect, new Point( _highlightenMargin, _highlightenMargin ) );
			_highlightenView.applyFilter( _highlightenView, _highlightenView.rect, new Point( 0, 0 ), _highlightenFilter );
		}
		
		public function Unhighlight() : void
		{
			for each ( var child : BliscDisplayObject in _children )
			{
				child.Unhighlight();
			}
			
			
			_highlighten = false;
			_highlightenMargin = 0;
			_highlightenFilter = null;
			if ( _highlightenView != null )
			{
				_highlightenView.dispose();
				_highlightenView = null;
			}
		}
		
		public function get highlighten() : Boolean
		{
			return _highlighten;
		}
		
		public function SetAlpha( alpha : int ) : void
		{
			for each ( var child : BliscDisplayObject in _children )
			{
				child.SetAlpha( alpha );
			}
			
			_alpha = alpha;
		}
		
		public function GetAlpha() : int
		{
			return _alpha;
		}
		
		/** Just makes invisible - doesn't removes regions from affecing tiles. Use Hide() for that purpose.*/
		public function SetVisibility( value : Boolean ) : void
		{
			_visibility = value;
		}
		public function GetVisibility() : Boolean
		{
			return _visibility;
		}
		
		/** Completely removes display object from map (everything but visual elements), but this removal can be easily restored using Show().*/
		public function Hide() : void
		{
			if ( _hidden )
			{
				return;
			}
			
			BeforePosChange();
			
			_hidden = true;
		}
		
		public function Show() : void
		{
			if ( _hidden == false )
			{
				return;
			}
			
			_hidden = false;
			
			HandlePosChange();
		}
		
		public function DisplaceX( how : Number ) : void
		{
			_visualDisp.x = how;
			
			ResolveGlobalPos();
		}
		
		public function DisplaceY( how : Number ) : void
		{
			_visualDisp.y = how;
			
			ResolveGlobalPos();
		}
	}
}



