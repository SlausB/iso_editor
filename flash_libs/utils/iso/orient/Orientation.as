/// @cond
package iso.orient
{
/// @endcond
	
	/** Относительное расположение (север, восток, юг, запад, северо-восток...).*/
	public class Orientation
	{
		public static const N : int = 0;
		public static const NE : int = 1;
		public static const E : int = 2;
		public static const SE : int = 3;
		public static const S : int = 4;
		public static const SW : int = 5;
		public static const W : int = 6;
		public static const NW : int = 7;
		/** "undefined" */
		public static const U : int = 8;
		
		/** Сколько соседей у каждого тайла.*/
		public static const NEIGHBOURS : int = 8;
		
		public static function ToInt( asString : String ) : int
		{
			var lowerCaseOrientation : String = asString.toLowerCase();
			switch ( lowerCaseOrientation )
			{
				case "n": return N;
				case "ne": return NE;
				case "e": return E;
				case "se": return SE;
				case "s": return S;
				case "sw": return SW;
				case "w": return W;
				case "nw": return NW;
			}
			return U;
		}
		
		public static function ToString( asInt : int ) : String
		{
			switch ( asInt )
			{
				case N: return "n";
				case NE: return "ne";
				case E: return "e";
				case SE: return "se";
				case S: return "s";
				case SW: return "sw";
				case W: return "w";
				case NW: return "nw";
			}
			return "undefined";
		}
		
		/** Направление (вроде NE) в массив углов (отдельно N и E).*/
		public static function DirectionToAngles( direction : int ) : Array
		{
			switch ( direction )
			{
				case N: return [ N ];
				case NE: return [ N, E ];
				case E: return [ E ];
				case SE: return [ S, E ];
				case S: return [ S ];
				case SW: return [ S, W ];
				case W: return [ W ];
				case NW: return [ N, W ];
			}
			
			return [];
		}
		
		/** Returns angle in degrees relative to specified direction. North is zero.*/
		public static function ToDegrees( direction : int ) : Number
		{
			switch ( direction )
			{
				case N: return 0;
				case NE: return 45;
				case E: return 90;
				case SE: return 135;
				case S: return 180;
				case SW: return 225;
				case W: return 270;
				case NW: return 315;
			}
			
			return 0;
		}
		
		/** Возвращает направление, противоположное указанному.*/
		public static function Mirror( orientation : int ) : int
		{
			return ( ( orientation + 4 ) % 8 );
		}
		
		/** Примыкает ли первый тайл ко второму. Соприкосновение углами также считается примыканием. Одинаковые тайлы НЕ будут считаться примыкающими.*/
		public static function IsNeighbour( x1 : int, y1 : int, x2 : int, y2 : int ) : Boolean
		{
			const xD : int = Math.abs( x1 - x2 );
			const yD : int = Math.abs( y1 - y2 );
			//угловое соприкосновение:
			if ( xD == 1 && yD == 1 )
			{
				return true;
			}
			//боковое примыкание - тайлы должны лежать на одной оси и в ней быть соседями:
			return ( ( xD + yD ) == 1 );
		}
	}
}

