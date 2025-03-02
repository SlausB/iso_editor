/// @cond
package actions 
{
	
	/// @endcond
	
	public class Utils 
	{
		/** \brief Преобразование вещественного числа в целочисленное.*/
		public static function ToInt(value:Number): int
		{
			if(value >= 0.0) return (int)(value + 0.5);
			else return (int)(value - 0.5);
		}
		
        /** \brief Равны ли числа между собой с указанной допустимой разницей.
        \param epsilon Если разница между числами меньше или равна этому числу, то числа считаются равными.*/
        public static function IsEqual(value1:Number, value2:Number, epsilon:Number = 0.0001): Boolean
		{
			if(Math.abs(value1 - value2) <= epsilon) return true;
			else return false;
		}
		
        /** \brief Преобразование градусной меры угла в радианную.*/
        public static function DegreesToRadians(degrees:Number): Number
		{
			return degrees / 57.29577951308232088;
		}
		
        /** \brief Преобразование радианной меры угла в градусную.*/
        public static function RadiansToDegrees(radians:Number): Number
		{
			return radians * 57.29577951308232088;
		}
	}

}

