///@cond
package  
{
	import blisc.BliscDisplayObject;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import utils.Utils;
	
	///@endcond
	
	public class GridDrawer extends BliscDisplayObject 
	{
		private var _mapRight:Number;
		private var _mapDown:Number;
		
		private var _viewportWidth:Number = 0;
		private var _viewportHeight:Number = 0;
		
		/** Intermediate viewport-size canvas to dynamically draw grid and boundaries.*/
		private var _bitmapData:BitmapData;
		
		private static const WIDTH:Number = 100;
		private static const HEIGHT:Number = 100;
		
		private var _project:Project;
		
		
		public function GridDrawer( mapRight:Number, mapDown:Number, viewportWidth:Number, viewportHeight:Number, project:Project )
		{
			super( null, 0, 1 );
			
			_mapRight = mapRight;
			_mapDown = mapDown;
			
			SetViewport( viewportWidth, viewportHeight );
			
			_project = project;
		}
		
		override public function draw( canvas:BitmapData, mouseCanvas:BitmapData, cameraX:Number, cameraY:Number, mouseCullX:int, mouseCullY:int, mouseCullX2:int, mouseCullY2:int ) :void
		{
			if ( _viewportWidth == 0 || _viewportHeight == 0 )
			{
				return;
			}
			
			_bitmapData.fillRect( _bitmapData.rect, 0xFFFFFFFF );
			
			//where everything will be drawn:
			var grid:Sprite = new Sprite;
			
			//boundaries:
			function DrawClampedLine( start:ClampedPoint, end:ClampedPoint ): void
			{
				if ( start._fits && end._fits )
				{
					grid.graphics.moveTo( start.x - cameraX, start.y - cameraY );
					grid.graphics.lineTo( end.x - cameraX, end.y - cameraY );
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
			grid.graphics.lineStyle( 3, 0x780AFF );
			var upperLeft:ClampedPoint = Clamp( -_mapRight, -_mapDown );
			var upperRight:ClampedPoint = Clamp( _mapRight, -_mapDown );
			var lowerRight:ClampedPoint = Clamp( _mapRight, _mapDown );
			var lowerLeft:ClampedPoint = Clamp( -_mapRight, _mapDown );
			//upper boundary:
			DrawClampedLine( upperLeft, upperRight );
			//right boundary:
			DrawClampedLine( upperRight, lowerRight );
			//lower boundary:
			DrawClampedLine( lowerRight, lowerLeft );
			//left boundary:
			DrawClampedLine( lowerLeft, upperLeft );
			//finally draw boundary onto canvas:
			_bitmapData.draw( grid );
			
			//mesh:
			const X_TILE_BOUNDARY:Number = 4;
			const Y_TILE_BOUNDARY:Number = 4;
			var tileBitmapData:BitmapData = new BitmapData( _project._data._tileSize * 2.0 + X_TILE_BOUNDARY * 2.0, _project._data._tileSize + Y_TILE_BOUNDARY * 2.0 );
			var tileTemplate:Sprite = new Sprite;
			tileTemplate.graphics.lineStyle( 2, 0x00FF00 );
			tileTemplate.graphics.moveTo( X_TILE_BOUNDARY, Y_TILE_BOUNDARY );
			tileTemplate.graphics.lineTo( X_TILE_BOUNDARY + _project._data._tileSize, Y_TILE_BOUNDARY + _project._data._tileSize / 2.0 );
			tileTemplate.graphics.lineTo( X_TILE_BOUNDARY, Y_TILE_BOUNDARY + _project._data._tileSize );
			tileTemplate.graphics.lineTo( X_TILE_BOUNDARY - _project._data._tileSize, Y_TILE_BOUNDARY - _project._data._tileSize / 2.0 );
			tileTemplate.graphics.lineTo( X_TILE_BOUNDARY, Y_TILE_BOUNDARY );
			tileBitmapData.draw( tileTemplate );
			const X_STEP:Number = _project._data._tileSize * 2.0;
			const Y_STEP:Number = _project._data._tileSize;
			//starting from upper left corner:
			var gridX:Number = - ( Math.floor( _mapRight / X_STEP ) + 1 ) * X_STEP;
			var gridY:Number = - ( Math.floor( _mapDown / Y_STEP ) + 1 ) * Y_STEP;
			function FromX( xToY:Number, x:Number, y:Number ): Number
			{
				return - xToY / 2.0;
			}
			//length of viewport's left side which we must travel to draw all lines:
			var path:Number = _viewportHeight + _viewportWidth / 2.0;
			const TILES:int = Math.ceil( Math.ceil( _mapRight / _project._data._tileSize ) * Math.ceil( _mapDown / _project._data._tileSize ) );
			var tilePos:Point = new Point;
			var viewportRect:Rectangle = new Rectangle( cameraX, cameraY, _viewportWidth, _viewportHeight );
			var tileRect:Rectangle = new Rectangle( 0, 0, _project._data._tileSize * 2.0, _project._data._tileSize );
			var destPoint:Point = new Point;
			for ( var i:int = 0; i < TILES; ++i )
			{
				Utils.IsoSpriralFromTile( i, tilePos );
				tilePos.x *= _project._data._tileSize * 2.0;
				tilePos.y *= _project._data._tileSize;
				
				tileRect.x = tilePos.x - _project._data._tileSize;
				tileRect.y = tilePos.y;
				
				if ( viewportRect.intersects( tileRect ) )
				{
					destPoint.x = tileRect.x - cameraX;
					destPoint.y = tileRect.y - cameraY;
					_bitmapData.copyPixels( tileBitmapData, tileBitmapData.rect, destPoint );
				}
			}
			
			
			canvas.copyPixels( _bitmapData, _bitmapData.rect, new Point( 0, 0 ) );
		}
		
		override public function get width(): int
		{
			return _mapRight * 2.0;
		}
		
		override public function get height(): int
		{
			return _mapDown * 2.0;
		}
		
		public function SetViewport( width:Number, height:Number ): void
		{
			_viewportWidth = width;
			_viewportHeight = height;
			
			if ( _bitmapData != null )
			{
				_bitmapData.dispose();
			}
			_bitmapData = new BitmapData( _viewportWidth, _viewportHeight );
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

