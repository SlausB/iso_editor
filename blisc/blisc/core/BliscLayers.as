///@cond
/**
 * Copyright (C) 2011 by CJ Cenizal
 * Use this code to do whatever you want, just don't claim it as your own, because I wrote it. Not you!
 * Adapted by SlavMFM@gmail.com for engine-like usage. Cheers!
 */
package blisc.core
{
	import blisc.templates.BliscLayerTemplate;
	import flash.display.BitmapData;
	
	///@endcond

	
	public class BliscLayers
	{
		private var _isMoved : Boolean = false;
		
		public var _layers : Vector.< BliscLayer > = new Vector.< BliscLayer >;
		
		private var _blisc : Blisc;
		
		
		public function BliscLayers( blisc : Blisc )
		{
			_blisc = blisc;
		}
		
		public function Destroy() : void
		{
			_layers.length = 0;
			for each ( var layer : BliscLayer in _layers )
			{
				layer.Destroy();
			}
			_layers.length = 0;
		}
		
		/** Draw all layers onto specified canvas.
		\param cameraX X coordinate of upper left corner of the camera.
		\param cameraY Y coordinate of upper left corner of the camera.
		*/
		public function Draw(
			cameraX : Number,
			cameraY : Number,
			right : Number,
			down : Number,
			zoom : Number
		) : void
		{
			const length : int = _layers.length;
			for ( var i : int = 0; i < length; ++i )
			{
				_layers[ i ].draw(
					cameraX,
					cameraY,
					right,
					down,
					zoom
				);
			}
		}
		
		//===================================
		//		Objects.
		//===================================
		
		public function AddObject( object : BliscDisplayObject, layerId : String ) : void
		{
			Lookup( layerId ).add( object );
		}
		
		//===================================
		//		Layers.
		//===================================

		public function Add( template : BliscLayerTemplate, visible : Boolean = true ) : void
		{
			_layers.push( new BliscLayer( _blisc, template, visible, _layers.length ) );
		}
		
		public function Lookup( id : String ) : BliscLayer
		{
			for each ( var layer : BliscLayer in _layers )
			{
				if ( layer.id == id )
				{
					return layer;
				}
			}
			return null;
		}
		
	}
}



