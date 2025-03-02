
///@cond
package
{
	import flash.geom.Point;
	///@endcond
	
	/** \brief Получение 2D координат по "Кривой Безье" в зависимости от заданных точек.
	\details Кривая Безье - это кривая, траектория которой определяется позициями (И порядком) точек от которых генерируется эта кривая (см. <a href="http://ru.wikipedia.org/wiki/Кривая_Безье">википедию</a>). Количество точек может быть произвольным. Кривая всегда берёт начало из первой точки и заканчивается на последней. Координаты точек на кривой располагаются от 0 до 1, где 0 - это координата первой точки, относительно которой высчитывается кривая, а 1 - это координата последней точки.*/
	public class BezierCurve
	{
        /** Defining constructor because modern mxmlc displays warning when classes have no constructors.*/
        public function BezierCurve() : void {}

		/** \brief Удаление всех точек из массива точек.
		\details После удаления точек функцией GetPosition() будет возвращаться всегда нулевая точка (как и в случае с одной точкой), пока точек снова не станет >= 2.
		\sa Point */
		public function Clear(): void
		{
			points.length = 0;
		}
		
		/** \brief Добавление новой точки в массив точек.
		\details После добавления новой точки, следующие позиции на кривой будут высчитываться уже согласно и добавленной точки.
		\sa Point */
		public function AddPoint(point:Point): void
		{
			points.push(point);
		}
		
		/** \brief Получение точки на кривой Безье в зависимости от позиции (от 0 до 1) в кривой.
		\param segment Позиция на прямой, где 0 - это позиция первой точки, а 1 - позиция последней точки.
		\param thinkAboutBorders <b>true</b> - (по умолчанию) segment будет ужат в интервал от 0 до 1. Если segment будет задан больше 1, то будет приравнен 1, если меньше 0, то будет приравнен нулю; <b>false</b> - в процессе вычисления будет использоваться любое значение segment.
		\sa Point
		\return Возвращает структуру с координатами 2D точки. Если задано меньше двух точек, то будет возвращена точка с координатами {0; 0}.*/
		public function GetPosition(segment:Number, thinkAboutBorders:Boolean = true): Point
		{
			if(thinkAboutBorders)
			{
				//результаты вычислений за границами интервалов неопределённые, поэтому умещаем сегмент в подобающий интервал:
				if(segment > 1.0)
				{
					segment = 1.0;
				}
				else if(segment < 0.0)
				{
					segment = 0.0;
				}
			}
			
			//точка, которая будет возвращена:
			var point:Point = new Point;
			
			//чтобы не вызывать часто функцию size():
			const pointsQuantity:int = points.length;
			
			//если в массиве меньше двух точек, то вернуть нулевую точку:
			if(pointsQuantity < 2)
			{
				point.x = 0;
				point.y = 0;
				
				return point;
			}
			
			//нужно точку segment первой прямой (от точки 1 до точки 2) соеденить с точкой segment второй прямой (от точки 2 до точки 3) и так далее. Затем повторить те же самые действия для новых получившихся таким образом точек, которых будет на 1 точку меньше, чем изначально. Делать это до тех пор, пока не останется две точки, после чего взять из них точку segment и вернуть как точку кривой Безье:
			
			//если в массиве только две точки, то просто вернуть их segment:
			if(pointsQuantity == 2)
			{
				PositionBetween2Points(point, points[0], points[1], segment);
				return point;
			}
			
			//создаём новый массив, в который будут записываться текущие точки в процессе вычисления финальной точки:
			var currentPoints:Vector.<Point> = new Vector.<Point>;
			for(var copyingPoints:int = 0; copyingPoints < pointsQuantity; copyingPoints++)
			{
				currentPoints.push(new Point(points[copyingPoints].x, points[copyingPoints].y));
			}
			
			//цикл высчитывания финальной точки от изначального количества точек до тех пор, пока не останутся только 2 точки:
			for(var cycle:int = pointsQuantity - 1; cycle >= 2; cycle--)
			{
				//цикл формирования новых точек, которых станет на 1 меньше, из текущих, количество которых равно cycle:
				for(var pair:int = 0; pair < cycle; pair++)
				{
					PositionBetween2Points(currentPoints[pair], currentPoints[pair], currentPoints[pair + 1], segment);
				}
			}
			
			//после всех действий осталось только две точки, сенмент которых и нужно вернуть:
			PositionBetween2Points(point, currentPoints[0], currentPoints[1], segment);
			
			return point;
		}
		
		/** \brief Получение угла направления перемещения по кривой в указанной точке.
		\details Используется тригонометрическое исчисление углов. <b>В градусах.</b>
		\param segment Позиция на кривой, где 0 - это позиция первой точки, а 1 - позиция последней точки.
		\param d Ширина сегмента, используемого при вычислении соотношения dx к dy. Следует увеличивать при увеличении общей длины кривой и наоборот.
		\return Угол в <b>градусах</b> направления перемещения по кривой в указанной точке.*/
		public function GetDirection(segment:Number, d:Number = 0.01): Number
		{
			//какое значение будет делиться:
			var rightPoint:Number;
			//на что будет делиться значение:
			var leftPoint:Number;
			
			//если расположение позволяет спозиционировать порядковое расположение на кривой:
			if(segment >= d)
			{
				rightPoint = segment;
				leftPoint = segment - d;
			}
			else
			{
				rightPoint = d;
				leftPoint = 0.0;
			}
			
			var pointLeft:Point = GetPosition(leftPoint);
			var pointRight:Point = GetPosition(rightPoint);
			//dy переворачиваем, так как координаты здесь исчесляются сверху вниз, а в тригонометрии снизу вверх:
			const dy:Number = -(pointRight.y - pointLeft.y);
			const dx:Number = pointRight.x - pointLeft.x;
			const tangent:Number = dy / dx;
			const radians:Number = Math.atan(tangent);
			var degrees:Number = (radians * 57.2957795131);
			//преобразуем результат в тригонометрический угол вращения:
			if(dy >= 0.0)
			{
				//в первой четверти всё в порядке...
				
				//вторая четверть:
				if(dx < 0.0)
				{
					//исчисляется от -89.9999 до 0, а нужно от 89.9999 до 180:
					degrees = 180.0 + degrees;
				}
			}
			else
			{
				//третья четверть:
				if(dx < 0.0)
				{
					//исчисляется от 0 до 89.9999, а нужно от 180 до 269.9999:
					degrees = 180.0 + degrees;
				}
				//четвёртая четверть:
				else
				{
					//исчисляется от -90 до -0, а нужно от 270 до 360 (0):
					degrees = 360.0 + degrees;
				}
			}
			//чтобы не был равен -0 и 360:
			if(degrees <= 0.0 || degrees >= 360.0)
			{
				degrees = 0.0;
			}
			return degrees;
		}
		
		
		
		/** \brief Формирование точки как позиции на прямой, соединяющей две точки в зависимости от segment, где segment от 0 до 1.
		\details Используется в процессе вычисления окончательной позиции внутри функции BezierCurve::GetPosition() .*/
		private function PositionBetween2Points(fillingPoint:Point, point1:Point, point2:Point, segment:Number): void
		{
			fillingPoint.x = point1.x + segment * (point2.x - point1.x);
			fillingPoint.y = point1.y + segment * (point2.y - point1.y);
		}
		
		
		/** \brief Динамический массив точек.
		\details Изначально длина его равна 0. Если в массиве меньше двух точек, то функцией GetPosition() будет возвращаться точка с координатами {0; 0}.
		\sa Point
		\sa GetPosition()*/
		private var points:Vector.<Point> = new Vector.<Point>;
	}
}



