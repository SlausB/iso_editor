///@cond
package blisc.utils
{
	import blisc.core.Blisc;
	import blisc.core.BliscLayer;
	import blisc.core.BliscSprite;
	import blisc.render_policy.RenderPolicy;
	import blisc.templates.BliscComplexTemplate;
	import blisc.templates.BliscComplexWithinCompoundTemplate;
	import blisc.templates.BliscCompoundTemplate;
	import blisc.templates.BliscObjectTemplate;
	import com.junkbyte.console.Cc;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import utils.Utils;
	
	///@endcond
	
	
	/** Use to render some isometric object separately from any isometry or other objects.*/
	public class ObjectRenderer extends Sprite
	{
		private var _layered : Vector.< Layered > = new Vector.< Layered >;
		
		public var _object : BliscObjectTemplate;
		
		
		/** .
		\param blisc Just to obtain information about layers and tileSide.
		\param object To be rendered. Zero position is presered.
		*/
		public function ObjectRenderer( blisc : Blisc, object : BliscObjectTemplate, policy : RenderPolicy = null )
		{
			mouseChildren = false;
			mouseEnabled = false;
			
			_object = object;
			
			if ( object is BliscComplexTemplate )
			{
				var complex : BliscComplexTemplate = object as BliscComplexTemplate;
				RenderComplex( blisc, complex, 0, 0, policy );
			}
			else if ( object is BliscCompoundTemplate )
			{
				var compound : BliscCompoundTemplate = object as BliscCompoundTemplate;
				for each ( var bcwct : BliscComplexWithinCompoundTemplate in compound._complexes )
				{
					RenderComplex( blisc, bcwct._complex, bcwct._tileDisp.x, bcwct._tileDisp.y, policy );
				}
			}
			else
			{
				Cc.error( "E: ObjectRenderer.ObjectRenderer(): wrong object type." );
				addChild( Utils.RenderDebugSprite() );
			}
			
			_layered.sort( function( lesser : Layered, greater : Layered ) : int
			{
				if ( lesser._layerIndex < greater._layerIndex )
				{
					return -1;
				}
				if ( lesser._layerIndex > greater._layerIndex )
				{
					return 1;
				}
				
				if ( lesser._bitmap.y < greater._bitmap.y )
				{
					return -1;
				}
				if ( lesser._bitmap.y > greater._bitmap.y )
				{
					return 1;
				}
				return 0;
			} );
			for ( var i : int = 0; i < _layered.length; ++i )
			{
				var layered : Layered = _layered[ i ];
				addChild( layered._bitmap );
			}
		}
		
		private function RenderComplex(
			pBlisc : Blisc,
			complex : BliscComplexTemplate,
			tileX : Number,
			tileY : Number,
			policy : RenderPolicy
		) : void
		{
			var sprite : BliscSprite;
			if ( policy == null )
			{
				sprite = complex._view.Resolve();
			}
			else
			{
				sprite = policy.DoIt( complex._view );
			}
			if ( sprite == null )
			{
				return;
			}
			
			var bitmapData : BitmapData = new BitmapData( sprite._source.rect.width, sprite._source.rect.height );
			bitmapData.copyPixels( sprite._source, sprite._source.rect, new Point );
			
			var bitmap : Bitmap = new Bitmap( bitmapData );
			
			var planar : Point = Utils.FromIso( tileX * pBlisc.tileSide, tileY * pBlisc.tileSide, new Point );
			
			bitmap.x = planar.x + complex._disp.x + sprite._disp.x;
			bitmap.y = planar.y + complex._disp.y + sprite._disp.y;
			
			var layerIndex : int = 0;
			for each ( var layer : BliscLayer in pBlisc._layers._layers )
			{
				if ( layer.id == complex._layer )
				{
					layerIndex = layer._index;
					break;
				}
			}
			
			_layered.push( new Layered( layerIndex, bitmap ) );
		}
		
		public function Destroy() : void
		{
			Utils.RemoveAllChildren( this );
			
			_layered.length = 0;
			
			if ( parent != null )
			{
				parent.removeChild( this );
			}
			
			_object = null;
		}
		
	}

}
import flash.display.Bitmap;

class Layered
{
	public var _layerIndex : int;
	
	public var _bitmap : Bitmap;
	
	
	public function Layered( layerIndex : int, bitmap : Bitmap )
	{
		_layerIndex = layerIndex;
		_bitmap = bitmap;
	}
}

