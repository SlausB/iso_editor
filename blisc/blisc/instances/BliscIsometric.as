///@cond
package blisc.instances
{
	import blisc.core.Blisc;
	import blisc.core.BliscDisplayObject;
	import blisc.core.BliscSprite;
	import blisc.pathfinding.AStarNode;
	import com.junkbyte.console.Cc;
	import flash.filters.GlowFilter;
	import view.Viewable;
	
	///@endcond
	
	
	/** Static or unit object within isometric space.*/
	public class BliscIsometric implements Viewable
	{
		public var _blisc : Blisc;
		public var _opaqueData : *;
		
		
		public function BliscIsometric( opaqueData : *, blisc : Blisc )
		{
			_opaqueData = opaqueData;
			_blisc = blisc;
		}
		
		/** Must provide just any display object at least part of this one if not whole if possible.*/
		public function get bdo() : BliscDisplayObject
		{
			Cc.error( "E: BliscIsometric.get bdo(): pure virtual call." );
			return null;
		}
		
		public function get node() : AStarNode
		{
			return _blisc._aStar.grid.GetTileRealValued( GetTileX(), GetTileY() );
		}
		
		
		public function SetX( x : Number ) : void
		{
			Cc.error( "E: BliscIsometric.SetX(): pure virtual call." );
		}
		public function SetY( y : Number ) : void
		{
			Cc.error( "E: BliscIsometric.SetY(): pure virtual call." );
		}
		public function SetXY( x : Number, y : Number ) : void
		{
			Cc.error( "E: BliscIsometric.SetXY(): pure virtual call." );
		}
		public function GetX() : Number
		{
			Cc.error( "E: BliscIsometric.GetX(): pure virtual call." );
			return 0;
		}
		public function GetY() : Number
		{
			Cc.error( "E: BliscIsometric.GetY(): pure virtual call." );
			return 0;
		}
		public function SetIsoX( x : Number ) : void
		{
			Cc.error( "E: BliscIsometric.SetIsoX(): pure virtual call." );
		}
		public function SetIsoY( y : Number ) : void
		{
			Cc.error( "E: BliscIsometric.SetIsoY(): pure virtual call." );
		}
		public function SetIsoXY( x : Number, y : Number ) : void
		{
			Cc.error( "E: BliscIsometric.SetIsoXY(): pure virtual call." );
		}
		public function GetIsoX(): Number
		{
			Cc.error( "E: BliscIsometric.GetIsoX(): pure virtual call." );
			return 0;
		}
		public function GetIsoY(): Number
		{
			Cc.error( "E: BliscIsometric.GetIsoY(): pure virtual call." );
			return 0;
		}
		public function SetTileX( x : Number ): void
		{
			Cc.error( "E: BliscIsometric.SetTileX(): pure virtual call." );
		}
		public function SetTileY( y : Number ): void
		{
			Cc.error( "E: BliscIsometric.SetTileY(): pure virtual call." );
		}
		public function SetTileXY( x : Number, y : Number ) : void
		{
			Cc.error( "E: BliscIsometric.SetTileXY(): pure virtual call." );
		}
		public function GetTileX() : Number
		{
			Cc.error( "E: BliscIsometric.GetTileX(): pure virtual call." );
			return 0;
		}
		public function GetTileY() : Number
		{
			Cc.error( "E: BliscIsometric.GetTileY(): pure virtual call." );
			return 0;
		}
		public function Replicate( what : BliscSprite ): void
		{
			Cc.error( "E: BliscIsometric.Replicate(): pure virtual call." );
		}
		public function Destroy() : void
		{
			Cc.error( "E: BliscIsometric.Destroy(): pure virtual call." );
		}
		public function SetSelectable( toWhat : Boolean ) : void
		{
			Cc.error( "E: BliscIsometric.SetSelectable(): pure virtual call." );
		}
		public function SetAlpha( alpha : int ) : void
		{
			Cc.error( "E: BliscIsometric.SetAlpha(): pure virtual call." );
		}
		public function GetAlpha() : int
		{
			Cc.error( "E: BliscIsometric.GetAlpha(): pure virtual call." );
			return 0;
		}
		public function Highlight( glowFilter : GlowFilter ) : void
		{
			Cc.error( "E: BliscIsometric.Highlight(): pure virtual call." );
		}
		public function Unhighlight() : void
		{
			Cc.error( "E: BliscIsometric.Unhighlight(): pure virtual call." );
		}
		public function SetVisibility( value : Boolean ) : void
		{
			Cc.error( "E: BliscIsometric.SetVisibility(): pure virtual call." );
		}
		public function GetVisibility() : Boolean
		{
			Cc.error( "E: BliscIsometric.GetVisibility(): pure virtual call." );
			return true;
		}
		public function Show() : void
		{
			Cc.error( "E: BliscIsometric.Show(): pure virtual call." );
		}
		public function Hide() : void
		{
			Cc.error( "E: BliscIsometric.Hide(): pure virtual call." );
		}
		
		public function DisplaceX( how : Number ) : void
		{
			Cc.error( "E: BliscIsometric.DisplaceX(): pure virtual call." );
		}
		public function DisplaceY( how : Number ) : void
		{
			Cc.error( "E: BliscIsometric.DisplaceY(): pure virtual call." );
		}
		
		public function Animate( played : Number, cycle : Boolean = true ) : void
		{
			Cc.error( "E: BliscIsometric.Animate(): pure virtual call." );
		}
		
		public function get highlighten() : Boolean
		{
			Cc.error( "E: BliscIsometric.get highlighten(): pure virtual call." );
			return false;
		}
		
	}

}



