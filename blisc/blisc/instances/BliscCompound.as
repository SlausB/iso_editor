///@cond
package blisc.instances 
{
	import blisc.core.Blisc;
	import blisc.core.BliscDisplayObject;
	import blisc.core.BliscSprite;
	import blisc.pathfinding.AStarNode;
	import blisc.templates.BliscComplexTemplate;
	import blisc.templates.BliscComplexWithinCompoundTemplate;
	import blisc.templates.BliscCompoundTemplate;
	import blisc.templates.BliscObjectTemplate;
	import com.junkbyte.console.Cc;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import utils.Utils;
	
	///@endcond
	
	/** Allocated instance of specified template on a map .*/
	public class BliscCompound extends BliscIsometric
	{
		/** Template used to create this object. Can be BliscComplexTemplate.*/
		public var _template : BliscObjectTemplate;
		
		public var _complexes : Vector.< BliscComplexWithinCompound > = new Vector.< BliscComplexWithinCompound >;
		
		
		public function At( index : int ) : BliscComplexWithinCompound
		{
			return _complexes[ index ];
		}
		
		override public function get bdo() : BliscDisplayObject
		{
			return At( 0 )._complex._bdo;
		}
		
		public function get higher() : BliscDisplayObject
		{
			if ( _complexes.length <= 0 )
			{
				return null;
			}
			
			_complexes.sort( function( lesser : BliscComplexWithinCompound, greater : BliscComplexWithinCompound ) : Number
			{
				if ( lesser._complex._bdo._sortVal < greater._complex._bdo._sortVal )
				{
					return -1;
				}
				if ( lesser._complex._bdo._sortVal == greater._complex._bdo._sortVal )
				{
					return 0;
				}
				return 1;
			} );
			
			return _complexes[ _complexes.length - 1 ]._complex._bdo;
		}
		
		/**
		\param complexName Looking complex' name if not null.
		\param animationName Looking animation's name within specified complex or any (if complexName is null) or any if null.
		\param some True if need to return at least something (if there are) if nothing was found.
		.*/
		public function Find( complexName : String, animationName : String = null, layerName : String = null, some : Boolean = true ) : BliscComplex
		{
			if ( _complexes.length <= 0 )
			{
				return null;
			}
			
			for each ( var bcwc : BliscComplexWithinCompound in _complexes )
			{
				if ( complexName != null )
				{
					if ( bcwc._complex._template._name != complexName )
					{
						continue;
					}
				}
				
				if ( animationName != null )
				{
					if ( bcwc._complex._template._view._name != animationName )
					{
						continue;
					}
				}
				
				if ( layerName != null )
				{
					if ( bcwc._complex._template._layer != layerName )
					{
						continue;
					}
				}
				
				return bcwc._complex;
			}
			
			if ( some )
			{
				return At( 0 )._complex;
			}
			return null;
		}
		
		public function BliscCompound( opaqueData : *, blisc : Blisc, template : BliscObjectTemplate )
		{
			super( opaqueData, blisc );
			
			_template = template;
			
			
			var compound : BliscCompoundTemplate = template as BliscCompoundTemplate;
			if ( compound == null )
			{
				var fakeTemplate : BliscComplexWithinCompoundTemplate = new BliscComplexWithinCompoundTemplate( template as BliscComplexTemplate, new Point );
				_complexes.push( new BliscComplexWithinCompound( fakeTemplate, CreateComplex( template as BliscComplexTemplate ), new Point ) );
			}
			else
			{
				for each ( var withinCompound : BliscComplexWithinCompoundTemplate in compound._complexes )
				{
					var flatDisp : Point = new Point;
					Utils.FromIso( withinCompound._tileDisp.x * blisc.tileSide, withinCompound._tileDisp.y * blisc.tileSide, flatDisp );
					
					_complexes.push( new BliscComplexWithinCompound( withinCompound, CreateComplex( withinCompound._complex ), flatDisp ) );
				}
			}
		}
		
		private function CreateComplex( template : BliscComplexTemplate ) : BliscComplex
		{
			var bdo : BliscDisplayObject = new BliscDisplayObject( _blisc, _opaqueData, template._disp );
			bdo._layerId = template._layer;
			
			return new BliscComplex( template, bdo );
		}
		
		override public function Destroy() : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex.Destroy();
			}
			_complexes.length = 0;
			
			if ( _blisc != null )
			{
				if ( _blisc._overOpaqueData == _opaqueData )
				{
					_blisc._overOpaqueData = null;
				}
				
				_blisc = null;
			}
			
			_opaqueData = null;
		}
		
		/** If can be selected using mouse and must absorb mouse events.*/
		override public function SetSelectable( toWhat : Boolean ): void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetSelectable( toWhat );
			}
		}
		
		override public function SetX( x : Number ): void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetX( x + complex._flatDisp.x );
			}
		}
		override public function SetY( y : Number ): void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetY( y + complex._flatDisp.y );
			}
		}
		override public function SetXY( x : Number, y : Number) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetXY( x + complex._flatDisp.x, y + complex._flatDisp.y );
			}
		}
		
		override public function GetX() : Number
		{
			var complex : BliscComplexWithinCompound = _complexes[ 0 ];
			return complex._complex._bdo.GetX() - complex._flatDisp.x;
		}
		override public function GetY() : Number
		{
			var complex : BliscComplexWithinCompound = _complexes[ 0 ];
			return complex._complex._bdo.GetY() - complex._flatDisp.y;
		}
		
		override public function SetIsoX( x : Number ): void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetIsoX( x + complex._template._tileDisp.x * _blisc.tileSide );
			}
		}
		override public function SetIsoY( y:Number ): void
		{
			for each ( var complex:BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetIsoY( y + complex._template._tileDisp.y * _blisc.tileSide );
			}
		}
		override public function SetIsoXY( x : Number, y : Number) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetIsoXY( x + complex._template._tileDisp.x * _blisc.tileSide, y + complex._template._tileDisp.y * _blisc.tileSide );
			}
		}
		
		override public function GetIsoX() : Number
		{
			var complex : BliscComplexWithinCompound = _complexes[ 0 ];
			return complex._complex._bdo.GetIsoX() - complex._template._tileDisp.x * _blisc.tileSide;
		}
		override public function GetIsoY() : Number
		{
			var complex : BliscComplexWithinCompound = _complexes[ 0 ];
			return complex._complex._bdo.GetIsoY() - complex._template._tileDisp.y * _blisc.tileSide;
		}
		
		override public function SetTileX( x : Number ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetTileX( x + complex._template._tileDisp.x );
			}
		}
		override public function SetTileY( y : Number ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetTileY( y + complex._template._tileDisp.y );
			}
		}
		override public function SetTileXY( x : Number, y : Number ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetTileXY( x + complex._template._tileDisp.x, y + complex._template._tileDisp.y );
			}
		}
		
		override public function GetTileX() : Number
		{
			var complex : BliscComplexWithinCompound = _complexes[ 0 ];
			return complex._complex._bdo.GetTileX() - complex._template._tileDisp.x;
		}
		override public function GetTileY() : Number
		{
			var complex : BliscComplexWithinCompound = _complexes[ 0 ];
			return complex._complex._bdo.GetTileY() - complex._template._tileDisp.y;
		}
		
		override public function Replicate( what : BliscSprite ): void
		{
			bdo.Replicate( what );
		}
		
		override public function SetAlpha( alpha : int ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetAlpha( alpha );
			}
		}
		
		override public function Highlight( glowFilter : GlowFilter ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.Highlight( glowFilter );
			}
		}
		
		override public function Unhighlight() : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.Unhighlight();
			}
		}
		
		override public function SetVisibility( value : Boolean ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.SetVisibility( value );
			}
		}
		
		override public function GetVisibility() : Boolean
		{
			if ( _complexes.length > 0 )
			{
				return _complexes[ 0 ]._complex._bdo.GetVisibility();
			}
			return true;
		}
		
		override public function Show() : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.Show();
			}
		}
		
		override public function Hide() : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.Hide();
			}
		}
		
		/** Returns absolute coordinate of average object's tile's center.*/
		public function get center() : Point
		{
			var x : Number = 0;
			var y : Number = 0;
			
			for each ( var bcwc : BliscComplexWithinCompound in _complexes )
			{
				x += bcwc._complex._bdo.GetX() + 0.5;
				y += bcwc._complex._bdo.GetY() + 0.5;
			}
			
			return new Point( x / _complexes.length, y / _complexes.length );
		}
		
		override public function DisplaceX( how : Number ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.DisplaceX( how );
			}
		}
		
		override public function DisplaceY( how : Number ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.DisplaceY( how );
			}
		}
		
		override public function Animate( played : Number, cycle : Boolean = true ) : void
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				complex._complex._bdo.Replicate( complex._template._complex._view.Resolve( played, cycle ) );
			}
		}
		
		override public function get highlighten() : Boolean
		{
			for each ( var complex : BliscComplexWithinCompound in _complexes )
			{
				return complex._complex._bdo.highlighten;
			}
			
			return false;
		}
		
	}

}

