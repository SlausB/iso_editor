
///@cond
package utils
{
	///@endcond
	
	
	/** \brief Путь, состоящий из многих кривых Безье.
	\details Позиция на кривой получается от 0 до 1, где 0 - первая точка первой кривой, 1 - последняя точка последней кривой.
	\sa BezierCurve
	*/
	public class BezierCurvesPack
	{
		/** \brief Удаление всех кривых.
		\details После удаления кривых функцией GetPosition() будет возвращаться всегда нулевая точка.*/
		public function Clear(): void
		{
		}
		
		/** \brief Добавление новой кривой.
		\details Одна и та же кривая может быть добавлена многократно.*/
		public function AddCurve(BezierCurve curve): void
		{
		}
		
		/** \brief Получение точки на наборе кривых Безье в зависимости от позиции (от 0 до 1) в кривой.
		\param segment Позиция на прямой, где 0 - это позиция первой точки, а 1 - позиция последней точки. Будет ужат в эти рамки.
		\sa Point
		\return Возвращает структуру с координатами 2D точки. Если задано меньше двух точек, то будет возвращена точка с координатами {0; 0}.*/
		public function GetPosition(segment:Number): Point
		{
		}
		
		
		
		/** \brief Добавленные кривые.*/
		private var curves:Vector.<BezierCurve>;
		
		/** \brief Какой отрезок из интервала от 0 до 1 занимает одна кривая.*/
		private var curvesSection:Number;
	}
}


