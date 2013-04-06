///@cond
package  
{
	import blisc.core.BliscDisplayObject;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import project_data.Map;
	import utils.Utils;
	
	///@endcond
	
	public class GridDrawer extends BliscDisplayObject 
	{
		private var _map:Map;
		
		private var _viewportWidth:Number = 0;
		private var _viewportHeight:Number = 0;
		
		/** Intermediate viewport-size canvas to dynamically draw grid and boundaries.*/
		private var _bitmapData:BitmapData;
		
		private static const WIDTH:Number = 100;
		private static const HEIGHT:Number = 100;
		
		private var _project:Project;
		
		
		public function GridDrawer( map:Map, viewportWidth:Number, viewportHeight:Number, project:Project )
		{
			super( null, 0, 1, new Point );
			
			_map = map;
			
			SetViewport( viewportWidth, viewportHeight );
			
			_project = project;
		}
		
		override public function draw( canvas:BitmapData, mouseCanvas:BitmapData, cameraX:Number, cameraY:Number, mouseCullX:int, mouseCullY:int, mouseCullX2:int, mouseCullY2:int, zoom:Number ) :void
		{
			if ( _viewportWidth == 0 || _viewportHeight == 0 )
			{
				return;
			}
			
			//don't even fill bitmap's rectangle then:
			if ( _map._drawBorder == false && _map._drawGrid == false )
			{
				return;
			}
			
			_bitmapData.fillRect( _bitmapData.rect, 0 );
			
			
			if ( _map._drawGrid )
			{
				const X_TILE_BOUNDARY:Number = 4;
				const Y_TILE_BOUNDARY:Number = 4;
				var tileBitmapData:BitmapData = new BitmapData( _project._data._tileSize * 2.0 + X_TILE_BOUNDARY * 2.0, _project._data._tileSize + Y_TILE_BOUNDARY * 2.0, true, 0 );
				var tileTemplate:Sprite = new Sprite;
				tileTemplate.graphics.lineStyle( 2, 0x49C221 );
				//decrease tile size to create beautiful gap between tiles:
				const TILE_EXTINGUISH:Number = 3;
				const TILE_HALF:Number = _project._data._tileSize;
				//north:
				tileTemplate.graphics.moveTo( X_TILE_BOUNDARY + TILE_HALF, Y_TILE_BOUNDARY + TILE_EXTINGUISH );
				//east:
				tileTemplate.graphics.lineTo( X_TILE_BOUNDARY + TILE_HALF * 2.0 - TILE_EXTINGUISH, Y_TILE_BOUNDARY + TILE_HALF / 2.0 );
				//south:
				tileTemplate.graphics.lineTo( X_TILE_BOUNDARY + TILE_HALF, Y_TILE_BOUNDARY + TILE_HALF - TILE_EXTINGUISH );
				//west:
				tileTemplate.graphics.lineTo( X_TILE_BOUNDARY + TILE_EXTINGUISH, Y_TILE_BOUNDARY + TILE_HALF / 2.0 );
				//back to north:
				tileTemplate.graphics.lineTo( X_TILE_BOUNDARY + TILE_HALF, Y_TILE_BOUNDARY + TILE_EXTINGUISH );
				tileBitmapData.draw( tileTemplate, null, null, BlendMode.NORMAL );
				const TILES:int = Math.ceil( Math.ceil( _map._right / _project._data._tileSize + 3 ) * Math.ceil( _map._down / _project._data._tileSize * 2.0 + 3 ) ) * 4;
				var tilePos:Point = new Point;
				var boundaryRect:Rectangle = new Rectangle( -_map._right, -_map._down, _map._right * 2.0, _map._down * 2.0 );
				var viewportRect:Rectangle = new Rectangle( cameraX, cameraY, _viewportWidth / zoom, _viewportHeight / zoom );
				var tileRect:Rectangle = new Rectangle( 0, 0, _project._data._tileSize * 2.0, _project._data._tileSize );
				var destPoint:Point = new Point;
				for ( var i:int = 0; i < TILES; ++i )
				{
					Utils.IsoSpriralFromTile( i, tilePos );
					tilePos.x *= _project._data._tileSize;
					tilePos.y *= _project._data._tileSize;
					
					tileRect.x = tilePos.x - _project._data._tileSize;
					tileRect.y = tilePos.y;
					
					if ( boundaryRect.intersects( tileRect ) && viewportRect.intersects( tileRect ) )
					{
						destPoint.x = tileRect.x - cameraX - X_TILE_BOUNDARY;
						destPoint.y = tileRect.y - cameraY - Y_TILE_BOUNDARY;
						_bitmapData.copyPixels( tileBitmapData, tileBitmapData.rect, destPoint, null, null, true );
					}
				}
			}
			
			if ( _map._drawBorder )
			{
				var border:Sprite = new Sprite;
				//boundaries:
				function DrawClampedLine( start:ClampedPoint, end:ClampedPoint ): void
				{
					if ( start._fits && end._fits )
					{
						border.graphics.moveTo( start.x - cameraX, start.y - cameraY );
						border.graphics.lineTo( end.x - cameraX, end.y - cameraY );
					}
				}
				/** Snap coordinate to visible range. Marks result as inappropriate (not visible) if both coordinates was clamped.*/
				function Clamp( clampingX:Number, clampingY:Number ): ClampedPoint
				{
					var clamped:int = 0;
					
					if ( clampingX < cameraX )
					{
						clampingX = cameraX;
						++clamped;
					}
					else if ( clampingX > ( cameraX + _viewportWidth ) )
					{
						clampingX = cameraX + _viewportWidth;
						++clamped;
					}
					
					if ( clampingY < cameraY )
					{
						clampingY = cameraY;
						++clamped;
					}
					else if ( clampingY > ( cameraY + _viewportHeight ) )
					{
						clampingY = cameraY + _viewportHeight;
						++clamped;
					}
					
					if ( clamped >= 2 )
					{
						return new ClampedPoint( 0, 0, false );
					}
					
					return new ClampedPoint( clampingX, clampingY, true );
				}
				border.graphics.lineStyle( 3, 0x780AFF );
				var upperLeft:ClampedPoint = Clamp( -_map._right, -_map._down );
				var upperRight:ClampedPoint = Clamp( _map._right, -_map._down );
				var lowerRight:ClampedPoint = Clamp( _map._right, _map._down );
				var lowerLeft:ClampedPoint = Clamp( -_map._right, _map._down );
				//upper boundary:
				DrawClampedLine( upperLeft, upperRight );
				//right boundary:
				DrawClampedLine( upperRight, lowerRight );
				//lower boundary:
				DrawClampedLine( lowerRight, lowerLeft );
				//left boundary:
				DrawClampedLine( lowerLeft, upperLeft );
				//finally draw boundary onto canvas:
				_bitmapData.draw( border );
			}
			
			
			canvas.copyPixels( _bitmapData, _bitmapData.rect, new Point( 0, 0 ), null, null, true );
		}
		
		override public function get width(): int
		{
			return _map._right * 2.0;
		}
		
		override public function get height(): int
		{
			return _map._down * 2.0;
		}
		
		public function SetViewport( width:Number, height:Number ): void
		{
			_viewportWidth = width;
			_viewportHeight = height;
			
			if ( _bitmapData != null )
			{
				_bitmapData.dispose();
			}
			_bitmapData = new BitmapData( _viewportWidth, _viewportHeight, true, 0 );
		}
		
		override public function Destroy(): void
		{
			super.Destroy();
			
			_bitmapData.dispose();
			_bitmapData = null;
			
			_map = null;
			
			_project = null;
		}
	}

}
import flash.geom.Point;

class ClampedPoint extends Point
{
	public var _fits:Boolean = true;
	
	public function ClampedPoint( x:Number, y:Number, fits:Boolean )
	{
		super( x, y );
		
		_fits = fits;
	}
}

