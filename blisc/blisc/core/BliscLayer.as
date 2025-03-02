///@cond
/**
 * Copyright (C) 2011 by CJ Cenizal
 * Use this code to do whatever you want, just don't claim it as your own, because I wrote it. Not you!
 * Adapted by SlavMFM@gmail.com for engine-like usage. Cheers!
 */
package blisc.core
{
	import blisc.templates.BliscLayerTemplate;
	import com.junkbyte.console.Cc;
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	
	///@endcond
	
	
	public class BliscLayer
	{
		public var _visible : Boolean;
		
		//trying to speed-up sorting (it worked - read where it used):
		//public var _objects : Vector.< BliscDisplayObject > = new Vector.< BliscDisplayObject >;
		public var _objects : Array = [];
		/** Avoid sorting every frame.*/
		private var _sorted : int = 0;
		private static const SORT_EACH : int = 10;
		
		/** Invalidated by BliscDisplayObject when that one moved.*/
		public var _dirty : Boolean = true;
		/** True if list must be sorted within next update in any way.*/
		public var _forceSorting : Boolean = false;
		
		/** To resolve which layer is higher within some outside code.*/
		public var _index : int = -1;
		
		public var _template : BliscLayerTemplate;
		
		private var _blisc : Blisc;
		
		
		public function BliscLayer(
			blisc : Blisc,
			template : BliscLayerTemplate,
			visible : Boolean,
			index : int
		)
		{
			_blisc = blisc;
			_template = template;
			_visible = visible;
			_index = index;
		}
		
		public function Destroy() : void
		{
			for each ( var object : BliscDisplayObject in _objects )
			{
				object.Destroy();
			}
			_objects.length = 0;
		}
		
		/** Draw the whole layer onto canvas.
		\param cameraX X coordinate of upper left corner of the camera.
		\param cameraY Y coordinate of upper left corner of the camera.
		\param right Where visible area ends at right (cameraX + "viewport's width").
		\param down Where visible area ends at bottom (cameraY + "viewport's height").
		*/
		public function draw(
			cameraX : Number,
			cameraY : Number,
			right : Number,
			down : Number,
			zoom : Number
		) : void
		{
			//whole this function (without actual calls to draw() function) consumes 10 ms...
			
			if ( _visible == false )
			{
				return;
			}
			
			if ( DEBUG::profiling )
			{
				const sortingGot : int = getTimer();
			}
			if ( _dirty || _forceSorting )
			{
				if ( _forceSorting )
				{
					_forceSorting = false;
					_sorted = 0;
				}
				else
				{
					++_sorted;
					_sorted %= SORT_EACH;
				}
				
				//checking mobile productivity:
				if ( _sorted == 0 )
				{
					_dirty = false;
					
					//sortOn() consumes just ~1.5 ms (!) while sort() 20 ms (for Vector sortOn() still consumes the same as sort()):
					/*_objects.sort( function( lesser : BliscDisplayObject, greater : BliscDisplayObject ) : Number
					{
						if ( lesser._sortVal < greater._sortVal )
						{
							return -1;
						}
						if ( lesser._sortVal == greater._sortVal )
						{
							return 0;
						}
						return 1;
					} );*/
					_objects.sortOn( "_sortVal", Array.NUMERIC );
				}
			}
			if ( DEBUG::profiling )
			{
				const sortingActuallyGot : int = getTimer() - sortingGot;
				if ( sortingActuallyGot > 0 )
				{
					Cc.info( "I: BliscLayer.draw(): sorting got " + sortingActuallyGot.toString() + " ms." );
				}
			}
			
			//this part WITHOUT any other code within _blisc.draw() and WITHOUT actual call to "draw()" consumes 6 ms (!): (with call to "draw()" and still WITHOUT everything else - 20 ms):
			const length : int = _objects.length;
			for ( var i : int = 0; i < length; ++i )
			{
				var obj : BliscDisplayObject = _objects[ i ];
				
				if ( obj._sprite == null )
				{
					continue;
				}
				
				if ( obj._alpha <= 0 )
				{
					continue;
				}
				
				if ( obj._visibility == false || obj._hidden )
				{
					continue;
				}
				
				//if out of visible area:
				if (
					( obj._roundGlobal.x + obj._width ) < cameraX ||
					obj._roundGlobal.x > right ||
					( obj._roundGlobal.y + obj._height ) < cameraY ||
					obj._roundGlobal.y > down
				)
				{
					continue;
				}
				
				if ( CONFIG::stage3d )
				{
					if ( _blisc._limit >= Blisc.LIMIT )
					{
						return;
					}
				}
				
				//call to this function without any conditions consumes 22 ms:
				obj.draw(
					cameraX,
					cameraY,
					zoom
				);
				
				//speeding up mouse selection function:
				if ( _blisc._drawn == null )
				{
					_blisc._drawn = obj;
				}
				else
				{
					_blisc._drawnLast._drawnNext = obj;
				}
				_blisc._drawnLast = obj;
				obj._drawnNext = null;
			}
		}
		
		public function add( object : BliscDisplayObject ) : void
		{
			object.layer = this;
			_objects.push( object );
			
			_forceSorting = true;
		}
		
		public function remove( object : BliscDisplayObject ) : void
		{
			var index : int = _objects.indexOf( object );
			if ( index > -1 )
			{
				_objects.splice( index, 1 );
			}
			
			//object removing cannot cause objects order artifacts, so layer cannot become "dirty" by it...
		}
		
		public function get id() : String
		{
			return _template._name;
		}
	}
}

