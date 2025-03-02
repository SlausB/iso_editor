///@cond
package blisc.utils
{
	import blisc.core.BliscDisplayObject;
	import blisc.instances.BliscComplexWithinCompound;
	import blisc.instances.BliscCompound;
	import blisc.pathfinding.AStarNode;
	import blisc.templates.BliscRegion;
	import com.junkbyte.console.Cc;
	
	///@endcond
	
	
	/** Describes specified object's dimensions.*/
	public class Dimensions
	{
		/** Left tile coorinate.*/
		public var _x1 : int = int.MAX_VALUE;
		/** Up tile coordinate.*/
		public var _y1 : int = int.MAX_VALUE;
		/** Right tile coordinate.*/
		public var _x2 : int = int.MIN_VALUE;
		/** Down tile coordinate.*/
		public var _y2 : int = int.MIN_VALUE;
		
		/** [ x2 - x1 ] + 1.*/
		public var _width : int = 0;
		/** [ y2 - y1 ] + 1.*/
		public var _height : int = 0;
		
		
		public function Dimensions( compound : BliscCompound )
		{
			var aSingle : Boolean = false;
			
			for each ( var bcwc : BliscComplexWithinCompound in compound._complexes )
			{
				aSingle = true;
				
				bcwc._complex._bdo.ForEachAffectedTile( function( tile : AStarNode, region : BliscRegion ) : void
				{
					if ( tile._tileX < _x1 )
					{
						_x1 = tile._tileX;
					}
					
					if ( tile._tileX > _x2 )
					{
						_x2 = tile._tileX;
					}
					
					if ( tile._tileY < _y1 )
					{
						_y1 = tile._tileY;
					}
					
					if ( tile._tileY > _y2 )
					{
						_y2 = tile._tileY;
					}
				} );
			}
			
			if ( aSingle )
			{
				_width = Math.abs( _x2 - _x1 ) + 1;
				_height = Math.abs( _y2 - _y1 ) + 1;
			}
			else
			{
				Cc.error( "E: Dimensions.Dimensions(): specified compound doesn't have a single space." );
				
				_x1 = 0;
				_y1 = 0;
				_x2 = 0;
				_y2 = 0;
			}
		}
		
	}

}



