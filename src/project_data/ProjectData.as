///@cond
package project_data
{
	import utils.Utils;
	
	///@endcond
	
	/** Used to write into some file and read out of it.*/
	public class ProjectData 
	{
		/** Distance from tile's center to east.*/
		public var _tileSize : Number = 40;
		
		public var _resources : Vector.< Resource > = new Vector.< Resource >;
		
		public var _objects : Vector.< ObjectTemplate > = new Vector.< ObjectTemplate >;
		
		public var _maps : Vector.< Map > = new Vector.< Map >;
		
		/** In order of appearance (from lower to upper).*/
		public var _layers : Vector.< Layer > = new Vector.< Layer >;
		
		/** Where project generates AS3 files for future usage within game itself. Null if path wasn't specified yet.*/
		public var _generationFolder : String = null;
		
		public var _regions : Vector.< Region > = new Vector.< Region >;
		
		/** Not exactly for any existing unit - only that was specified.*/
		public var _unitProperties : Vector.< UnitProperties > = new Vector.< UnitProperties >;
		
		/** Maximum amount of adjacent neighbour tiles unit can slip through when walking over tile's angle (north, east, south, west).*/
		public var _slippingValue : int = 0;
		
		public var _sourcesDirectory : String = "";
		
		/** Which alpha value must be set to overlapping objects when deeper one is chosen. 0 - fully transparent, 255 - fully opaque.*/
		public var _throughAlpha : int = 100;
		
		/** All specified animation properties.*/
		public var _animationProperties : Vector.< AnimationProperties > = new Vector.< AnimationProperties >;
		
		/** Is it need to check if frames differ doing per-pixel check.*/
		public var _performPerPixelAnimationsCheck : Boolean = true;
		
		
		/** Returns any provided information for specified automatically generated unit. Null if no information was given for that unit.
		\param create True if need to create and add new one if wasn't found.
		*/
		public function FindUnitProperties( unitDesc : UnitDesc, create : Boolean ) : UnitProperties
		{
			for each ( var unitProperties : UnitProperties in _unitProperties )
			{
				if ( unitProperties._unit == unitDesc._template.MakeFullName() )
				{
					return unitProperties;
				}
			}
			
			if ( create )
			{
				var creating : UnitProperties = new UnitProperties;
				creating.Init( unitDesc._template.MakeFullName() );
				
				_unitProperties.push( creating );
				
				return creating;
			}
			
			return null;
		}
		
		public function get side(): Number
		{
            return _tileSize * Utils.TILE_SIDE;
		}
	}

}

