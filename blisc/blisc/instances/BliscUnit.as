///@cond
package blisc.instances 
{
	import blisc.core.Blisc;
	import blisc.core.BliscDisplayObject;
	import blisc.core.BliscSprite;
	import blisc.pathfinding.AStarNode;
	import blisc.templates.BliscUnitTemplate;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	///@endcond
	
	
	/** Specifically unit object within isometric space.*/
	public class BliscUnit extends BliscIsometric
	{
		public var _template : BliscUnitTemplate;
		
		public var _bdo : BliscDisplayObject;
		
		
		public function BliscUnit( template : BliscUnitTemplate, opaqueData : *, blisc : Blisc, layer : String )
		{
			super( opaqueData, blisc );
			
			_template = template;
			
			_bdo = new BliscDisplayObject( blisc, opaqueData, new Point, false );
			_bdo._layerId = layer;
		}
		
		override public function get bdo() : BliscDisplayObject
		{
			return _bdo;
		}
		
		override public function Destroy() : void
		{
			if ( _blisc._overOpaqueData == _opaqueData )
			{
				_blisc._overOpaqueData = null;
			}
			
			_bdo.Destroy();
			_bdo = null;
			
			_opaqueData = null;
			_blisc = null;
		}
		
		/** If can be selected using mouse and must absorb mouse events.*/
		override public function SetSelectable( toWhat : Boolean ) : void
		{
			_bdo.SetSelectable( toWhat );
		}
		
		override public function SetX( x:Number ): void
		{
			_bdo.SetX( x );
		}
		override public function SetY( y:Number ): void
		{
			_bdo.SetX( y );
		}
		override public function GetX() : Number
		{
			return _bdo.GetX();
		}
		override public function GetY() : Number
		{
			return _bdo.GetY();
		}
		
		override public function SetIsoX( x : Number ) : void
		{
			_bdo.SetIsoX( x );
		}
		override public function SetIsoY( y : Number ) : void
		{
			_bdo.SetIsoY( y );
		}
		override public function SetIsoXY( x : Number, y : Number ) : void
		{
			_bdo.SetIsoXY( x, y );
		}
		override public function GetIsoX() : Number
		{
			return _bdo.GetIsoX();
		}
		override public function GetIsoY() : Number
		{
			return _bdo.GetIsoY();
		}
		
		override public function SetTileX( x : Number ) : void
		{
			_bdo.SetTileX( x );
		}
		override public function SetTileY( y : Number ) : void
		{
			_bdo.SetTileY( y );
		}
		override public function SetTileXY( x : Number, y : Number) : void
		{
			_bdo.SetTileXY( x, y );
		}
		override public function GetTileX() : Number
		{
			return _bdo.GetTileX();
		}
		override public function GetTileY() : Number
		{
			return _bdo.GetTileY();
		}
		
		override public function Replicate( what : BliscSprite ) : void
		{
			_bdo.Replicate( what );
		}
		
		override public function Highlight( glowFilter : GlowFilter ) : void
		{
			_bdo.Highlight( glowFilter );
		}
		
		override public function Unhighlight() : void
		{
			_bdo.Unhighlight();
		}
		
		override public function SetAlpha( alpha : int ) : void
		{
			_bdo.SetAlpha( alpha );
		}
		
		override public function GetAlpha() : int
		{
			return _bdo.GetAlpha();
		}
		
	}

}



