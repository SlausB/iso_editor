///@cond
package view 
{
	import blisc.core.BliscSprite;
	import flash.filters.GlowFilter;
	
	///@endcond
	
	/** Basic way to communicate with object's viewing representation.*/
	public interface Viewable 
	{
		/** Screen coordinates.*/
		function SetX( x : Number ) : void;
		function SetY( y : Number ) : void;
		function SetXY( x : Number, y : Number ) : void;
		function GetX() : Number;
		function GetY() : Number;
		
		/** Physical isometric coordinates.*/
		function SetIsoX( x : Number ) : void;
		function SetIsoY( y : Number ) : void;
		function SetIsoXY( x : Number, y : Number ) : void;
		function GetIsoX() : Number;
		function GetIsoY() : Number;
		
		/** Logical isometric coordinates. Integer values supposed.*/
		function SetTileX( x : Number ): void;
		function SetTileY( y : Number ): void;
		function SetTileXY( x : Number, y : Number ) : void;
		function GetTileX() : Number;
		function GetTileY() : Number;
		
		/** Make this object look like this.*/
		function Replicate( what : BliscSprite ) : void;
		
		function Destroy() : void;
		
		/** If can be selected using mouse and must absorb mouse events.*/
		function SetSelectable( toWhat:Boolean ) : void;
		
		/** 0 - fully transparent, 255 - opaque.*/
		function SetAlpha( alpha : int ) : void;
		
		/** Draw border around an object. Passed glowFilter will be used earlier on some conditions, so do not modify it.*/
		function Highlight( glowFilter : GlowFilter ) : void;
		function Unhighlight() : void;
		
		function SetVisibility( value : Boolean ) : void;
		function GetVisibility() : Boolean;
	}
	
}

