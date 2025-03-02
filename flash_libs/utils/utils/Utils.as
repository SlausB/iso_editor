/// @cond
package utils
{
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.text.TextDisplayMode;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	/// @endcond
	
	/** Утилиты, не ассоциируемые с конкретным исопльзованием.*/
	public class Utils
	{
		/** Угол наклона линии в изометрии - в градусах.*/
		public static const ISO_SLOPE : Number = 30;
		/** Cosine of isometric angle ( ISO_SLOPE ) or half of sqrt(3) - multiply planar X on this value to get X isometric position.*/
		public static const ISO_SLOPE_COS : Number = 0.86602540378443864676372317075294;
		/** Синус от ISO_SLOPE - умножать планарную координату Y на это число для получения изометрической координаты Y.*/
		public static const ISO_SLOPE_SIN : Number = 0.5;
		/** Length of tile's side within single axis.*/
		public static const ISO_UNIFIED_SIDE_LENGTH : Number = 1.0 / ISO_SLOPE_COS;
		/** Distance from tile's north corner to east if distance from tile's center to east corner is 1. Single tile upon some isometric axis.*/
		public static const TILE_SIDE : Number = 1.1180339887498948482045868343656;
		

        public static function postpone( func : Function ) {
			var timer : Timer = new Timer( 120, 1 );
			timer.addEventListener(
                TimerEvent.TIMER_COMPLETE,
                function() : void {
                    func()
                }
            )
            timer.start()
        }
		
		/** Удаление всех элементов из контейнера.*/
		public static function RemoveAllChildren( displayObjectContainer : DisplayObjectContainer ) : void
		{
			while ( displayObjectContainer.numChildren > 0 )
			{
				displayObjectContainer.removeChildAt( displayObjectContainer.numChildren - 1 );
			}
		}
		
		/** Задание цвета по его компонентам.
		\param red Красная компонента цвета - от 0 до 255.
		\param green Зелёная компонента цвета - от 0 до 255.
		\param blue Синяя компонента цвета - от 0 до 255.*/
		public static function ByteColor( red : int, green : int, blue : int) : int
		{
			return ( ( ( red << 16 ) | green << 8 ) | blue );
		}
		
		public static function RandomColor() : uint
		{
			return ByteColor(
				Math.floor( Math.random() * 256 ),
				Math.floor( Math.random() * 256 ),
				Math.floor( Math.random() * 256 )
			);
		}
		
		/** Проверка на равенство двух вещественных чисел в указанном диапазоне.*/
		public static function IsEqual( value1 : Number, value2 : Number, epsilon : Number = 0.00001 ) : Boolean
		{
			return Math.abs( value2 - value1 ) <= epsilon;
		}
		
		/** Добавить в объект все свойства указанного объекта. Равносильно слиянию двух объектов в один.*/
		public static function SetProperty( object : Object, properties : Object ) : Object
		{
			for ( var p : String in properties )
			{
				object[ p ] = properties[ p ];
			}

			return object;
		}
		
		/** Нарисовать линию по траектории, заданной уравнением "y = k*x + b", подставляя X.*/
		public static function DrawLineX( sprite : Sprite, xStart : Number, xEnd : Number, k : Number, b : Number ) : void
		{
			sprite.graphics.moveTo( xStart, k * xStart + b );
			sprite.graphics.lineTo( xEnd, k * xEnd + b );
		}
		
		/** Нарисовать линию по траектории, заданной уравнением "y = k*x + b", подставляя Y.*/
		public static function DrawLineY(sprite:Sprite, yStart:Number, yEnd:Number, k:Number, b:Number): void
		{
			sprite.graphics.moveTo((yStart - b) / k, yStart);
			sprite.graphics.lineTo((yEnd - b) / k, yEnd);
		}
		
		/** Нарисовать изометрическую рамку, где ноль - это северная точка рамки.
		\param width Сколько тайлов должна занимать рамка с севера на восток.
		\param height Сколько тайлов должна занимать рамка с севера на запад.
		*/
		public static function DrawIsometricFrame(sprite:Sprite, width:int, height:int): void
		{
			/*sprite.graphics.moveTo(0, 0);
			//восток:
			var point:Point = Tile.GetDisplacement(width, 0);
			sprite.graphics.lineTo(Tile.tileWidthHalf * width, Tile.tileHeightHalf * width);
			sprite.graphics.lineTo(point.x, point.y);
			//юг:
			point = Tile.GetDisplacement(width, height);
			sprite.graphics.lineTo((tileWidthHalf * width) - (tileWidthHalf * height), tileHeightHalf * (width + height));
			sprite.graphics.lineTo(point.x, point.y);
			//запад:
			point = Tile.GetDisplacement(0, height);
			sprite.graphics.lineTo( -(tileWidthHalf * height), tileHeightHalf * height);
			sprite.graphics.lineTo(point.x, point.y);
			//север:
			sprite.graphics.lineTo(0, 0);*/
		}
		
		public static function DegreesToRadians( degrees :Number ) : Number
		{
			return degrees / 57.295779513082320876798154814105;
		}
		
		public static function RadiansToDegrees( radians : Number ) : Number
		{
			return radians * 57.295779513082320876798154814105;
		}
		
		/** Scale object so that he will fit specified bounds.
		\return Passed displayObject.*/
		public static function Scale( displayObject : DisplayObject, requiredWidth : Number, requiredHeight : Number ) : DisplayObject
		{
			var resultScale : Number = Math.min( requiredWidth / displayObject.width, requiredHeight / displayObject.height );
			
			displayObject.scaleX = resultScale;
			displayObject.scaleY = resultScale;
			
			return displayObject;
		}
		
		/** Копирование всех элементов массива.*/
		public static function CopyArray(to:Array, from:Array): void
		{
			for each(var object:Object in from)
			{
				to.push(object);
			}
		}
		
		/** Отрисовка картинки, информирующей об ошибке.*/
		public static function RenderDebugSprite() : Sprite
		{
			var defaultDisplayObject : Sprite = new Sprite;
			defaultDisplayObject.graphics.clear();
			defaultDisplayObject.graphics.beginFill( 0xFFFF00 );
			defaultDisplayObject.graphics.drawRect( 0, 0, 20, 20 );
			defaultDisplayObject.graphics.endFill();
			defaultDisplayObject.graphics.lineStyle( 1.0, 0xFF0000 );
			defaultDisplayObject.graphics.moveTo( 0, 0 );
			defaultDisplayObject.graphics.lineTo( 20, 20 );
			defaultDisplayObject.graphics.moveTo( 20, 0 );
			defaultDisplayObject.graphics.lineTo( 0, 20 );
			return defaultDisplayObject;
		}
		
		/** Center first display object within second one.*/
		public static function Center( which : DisplayObject, where : DisplayObjectContainer ) : DisplayObject
		{
			which.x = ( where.width - which.width ) / 2.0;
			which.y = ( where.height - which.height ) / 2.0;
			return which;
		}
		
		/** Make so that object will be displayed around it's point. Further object's x/y properties must be changed relatively.*/
		public static function CenterItself( what : DisplayObject ) : DisplayObject
		{
			var bounds : Rectangle = what.getBounds( what );
			what.x = - ( bounds.x + ( bounds.width * what.scaleX / 2.0 ) );
			what.y = - ( bounds.y + ( bounds.height * what.scaleY / 2.0 ) );
			return what;
		}
		
		/** Возвращает случайное целочисленное значение в указанном интервале, включая to.*/
		static public function RandomInt( from : int, to : int ) : int
		{
			if ( from == to )
			{
				return from;
			}
			else if ( from > to )
			{
				return RandomInt( to, from );
			}
			
			return from + Math.random() * ( to - from + 1 );
		}
		
		/** */
		static public function RandomUInt( from : uint, to : uint ) : uint
		{
			if ( from == to )
			{
				return from;
			}
			else if ( from > to )
			{
				return RandomUInt( to, from );
			}
			else
			{
				return from + Math.random() * ( to - from + 1 )
			}
		}
		
		/** value should always be between 0.0 – 1.0. Places value into desired range of low – high */
		public static function Lerp( value : Number, low : Number, high : Number ) : Number
		{
			return value * ( high - low ) + low;
		}
		
		/** */
		static public function IsEmpty( array : Array ) : Boolean
		{
			for ( var strItem : String in array )
			{
				return false;
			}
			return true;
		}
		
		/** */
		static public function MakeRGBA( r : uint, g : uint, b : uint, a : uint) : uint
		{
			return ( ( ( a & 0xff ) << 24 ) | ( ( r & 0xff ) << 16 ) | ( ( g & 0xff ) << 8 ) | ( b & 0xff ) );
		}
		
		/** */
		static public function Compare( val1 : * , val2 : * ) : int
		{
			return val1 == val2 ? 0 : val1 > val2 ? 1 : -1;
		}
		
		/** Возвращает склонение именования количества, подходящее для указанного числа единиц.
		На примере слова "конфета":
		\param amount Количество единиц, для которых нужно найти склонение.
		\param zero Ноль, четыре-двадцать конфет.
		\param one Одна конфета.
		\param two Две-три конфеты.
		*/
		static public function FindDeclention( amount : int, zero : String, one : String, two : String ) : String
		{
			if ( amount < 0 )
			{
				amount = -amount;
			}
			
			const hundred : int = amount % 100;
			if ( hundred >= 10 && hundred <= 20 )
			{
				return zero;
			}
			
			const ten : int = hundred % 10;
			if ( ten <= 0 )
			{
				return zero;
			}
			else if ( ten == 1 )
			{
				return one;
			}
			else if ( ten <= 3 )
			{
				return two;
			}
			else
			{
				return zero;
			}
		}
		
		/** Возвращает длину окружности, состоящей из указанного радиуса.*/
		static public function MaxCircle( radius : int ) : int
		{
			//центр круга:
			var length : int = 1;
			//добавления по краям вокруг центра:
			const sideAdd : int = radius * 2;
			length += sideAdd;
			//ещё две стороны, которые примыкают к первой только что добавленной:
			length += sideAdd * 2;
			length += sideAdd - 1;
			return length;
		}
		
		/** Returns max tile index for given tile radius ( to use with SpiralFromTile(...) )
		 * I.e. GetMaxTileIndexForRadius(1) = 7; GetMaxTileIndexForRadius(2) = 7 + 15 */
		/*static public function GetMaxTileIndexForRadius(radius:int): int
		{
			if ( radius < 1 )
				return 0;
			
			var maxTileIndex:int = 0;
			for (var circleIndex:int = 0; circleIndex <= radius; ++circleIndex)
				maxTileIndex += Utils.MaxCircle(circleIndex);
				
			return maxTileIndex - 1;
		}*/
		
		/** Возвращает координату в спирале вокруг указанного тайла, исключая сам этот тайл - изометрический эквивалент полярной системы координат.
		Возвращает null если index отрицательный.
		Поиск начинается с северного тайла (под нулевым индексом) первой окружности вокруг указанного тайла итерируясь по часовой стрелке. После чего (по прохождении всех восьми окружающих тайлов) итерация продолжается с северного тайла второй окружности и так далее.
		\param x,y Тайл, в радиусе вокруг которого нужно искать итерироваться.
		\param index Индекс искомой координаты при итерации по окружности от нуля до "количества тайлов минус один".
		*/
		static public function SpiralFromTile( x : Number, y : Number, index : int) : Point
		{
			if (index < 0)
			{
				return null;
			}
			
			//ищем окружность, внутри которой находится искомый индекс:
			var currentLength:int = 0;
			var foundRadius:int = -1;
			//цикл-то вечный, но, когда-нибудь, всё-таки будет найден подходящий радиус:
			for (var currentRadius:int = 1; ; currentRadius++)
			{
				const currentCirleRadius:int = MaxCircle(currentRadius);
				
				if (index < (currentLength + currentCirleRadius))
				{
					foundRadius = currentRadius;
					break;
				}
				
				currentLength += currentCirleRadius;
			}
			
			if (foundRadius < 0)
			{
				return null;
			}
			
			//идем конкретную координату внутри найденной окружности ( скобка "[" означает "включительно" и наоборот):
			
			//начинаем с северной точки:
			var foundX:int = x - foundRadius;
			var foundY:int = y - foundRadius;
			
			if (index <= currentLength)
			{
				return new Point(foundX, foundY);
			}
			
			//длина одной целой части окружности равна самому центральному тайлу и дополнений по его бокам:
			const sideLength:int = 1 + (foundRadius * 2);
			
			//[север, восток] (на северной точке было установлено изначально - проверять не нужно):
			//переходим в конец стороны:
			foundX += sideLength - 1;
			currentLength += sideLength - 1;
			//если прошли искомый тайл:
			if (index <= currentLength)
			{
				//возвращаемся к искомому тайлу на столько, на сколько мы его пропустили:
				foundX -= currentLength - index;
				return new Point(foundX, foundY);
			}
			
			//(восток, юг]:
			foundY += sideLength - 1;
			currentLength += sideLength - 1;
			if (index <= currentLength)
			{
				foundY -= currentLength - index;
				return new Point(foundX, foundY);
			}
			
			//(юг, запад]:
			foundX -= sideLength - 1;
			currentLength += sideLength - 1;
			if (index <= currentLength)
			{
				foundX += currentLength - index;
				return new Point(foundX, foundY);
			}
			
			//(запад, север):
			foundY -= sideLength - 2;
			currentLength += sideLength - 2;
			if (index <= currentLength)
			{
				foundY += currentLength - index;
				return new Point(foundX, foundY);
			}
			
			//здесь никогда не окажемся:
			return null;
		}
		
		/** Fills toFill with isometric coordinates (each tile having 4 neighbours) (assuming width and height = 1 ( the length between any 2 anjusting corners (length of one side) ) and starting position = {0;0} ) spiralling from some starting position (at index 0) clockwise. Tile at index 1 is at south-east to tile at index 0. The same as HexSpiralFromTile() but for square tiles.*/
		public static function IsoSpriralFromTile( index : int, toFill : Point ) : void
		{
			toFill.x = 0;
			toFill.y = 0;
			
			//resolve circle first:
			var remainder : int = index - 1;
			var radius : int = 0;
			for ( ;; )
			{
				var nextRemainder : int = remainder - ( ( radius * 2 ) * 4 );
				if ( nextRemainder < 0 )
				{
					break;
				}
				remainder = nextRemainder;
				++radius;
			}
			
			toFill.y = -radius;
			
			var direction : int = 0;
			
			const step : int = radius * 2;
			
			for ( ;; )
			{
				if ( remainder <= 0 )
				{
					break;
				}
				
				const moves : int = Math.min( step, remainder );
				toFill.x += isoSpriralFromTile_directions[ direction ].x * moves;
				toFill.y += isoSpriralFromTile_directions[ direction ].y * moves;
				remainder -= step;
				++direction;
			}
		}
		/** Used by IsoSpriralFromTile().*/
		/*private static var isoSpriralFromTile_directions:Vector.< Point > = new < Point >[
			new Point( ISO_SLOPE_COS, ISO_SLOPE_SIN ),
			new Point( -ISO_SLOPE_COS, ISO_SLOPE_SIN ),
			new Point( -ISO_SLOPE_COS, -ISO_SLOPE_SIN ),
			new Point( ISO_SLOPE_COS, -ISO_SLOPE_SIN ),
		];*/
		private static var isoSpriralFromTile_directions : Vector.< Point > = new < Point >[
			new Point( 1.0, 0.5 ),
			new Point( -1.0, 0.5 ),
			new Point( -1.0, -0.5 ),
			new Point( 1.0, -0.5 ),
		];
		
		/** Fills toFill with hex' coordinates (each tile having 6 neighbours) (assuming width and height = 1 ( the length between any 2 anjusting corners (length of one side) ) and starting position = {0;0} ) spiralling from some starting position (at index 0) clockwise. Hex at index 1 is at south-east to hex at index 0.*/
		public static function HexSpriralFromTile( index:int, toFill:Point ): void
		{
			toFill.x = 0;
			toFill.y = 0;
			
			//resolve circle first:
			var subtrahend:int = 0;
			var remainder:int = index - 1;
			var radius:int = 0;
			for ( ;; )
			{
				var nextRemainder:int = remainder - subtrahend;
				if ( nextRemainder < 0 )
				{
					break;
				}
				remainder = nextRemainder;
				++radius;
				subtrahend += 6;
			}
			
			toFill.y = -HEX_HEIGHT * radius;
			
			
			var direction:int = 0;
			var moves:int = 0;
			
			for ( var i:int = 0; i < remainder; ++i )
			{
				toFill.x += hexSpriralFromTile_directions[ direction ].x;
				toFill.y += hexSpriralFromTile_directions[ direction ].y;
				++moves;
				if ( moves >= radius )
				{
					++direction;
					moves = 0;
				}
			}
		}
		private static const HEX_HEIGHT_HALF:Number = 0.86602540378443864676372317075294;
		private static const HEX_HEIGHT:Number = HEX_HEIGHT_HALF * 2.0;
		/** Used by HexSpriralFromTile().*/
		private static var hexSpriralFromTile_directions:Vector.< Point > = new < Point >[
			new Point( 1.5, HEX_HEIGHT_HALF ),
			new Point( 0, HEX_HEIGHT ),
			new Point( -1.5, HEX_HEIGHT_HALF ),
			new Point( -1.5, -HEX_HEIGHT_HALF ),
			new Point( 0, -HEX_HEIGHT ),
			new Point( 1.5, -HEX_HEIGHT_HALF )
		];
		
		/** Remove all repeating elements from array
		\return The passed array.*/
		public static function Unify( what : Vector.< int > ) : Vector.< int >
		{
			for ( var i1 : int = 0; i1 < what.length; ++i1 )
			{
				//looking for copy:
				for ( var i2 : int = i1 + 1; i2 < what.length; ++i2 )
				{
					if ( what[ i1 ] == what[ i2 ] )
					{
						what.splice( i1, 1 );
						//to check moved element too:
						--i1;
						break;
					}
				}
			}
			
			return what;
		}
		
		public static function FromIso( x : Number, y : Number, toFill : Point ) : Point
		{
			/*toFill.x = x * ISO_SLOPE_COS - y * ISO_SLOPE_COS;
			toFill.y = x * ISO_SLOPE_SIN + y * ISO_SLOPE_SIN;*/
			
			x /= TILE_SIDE;
			y /= TILE_SIDE;
			toFill.x = x - y;
			toFill.y = ( x + y ) / 2.0;
			
			return toFill;
		}
		
		public static function ToIso( x : Number, y : Number, toFill : Point ) : Point
		{
			/*toFill.x = x * ISO_SLOPE_SIN + y * ISO_SLOPE_COS;
			toFill.y = -x * ISO_SLOPE_SIN + y * ISO_SLOPE_COS;*/
			//toFill.x = x * ISO_SLOPE_COS + y;
			//toFill.y = -x * /*ISO_SLOPE_COS*/0.75 + y;
			
			toFill.x = ( x / 2.0 + y ) * TILE_SIDE;
			toFill.y = ( y - x / 2.0 ) * TILE_SIDE;
			
			return toFill;
		}
		
		/** Возвращает плоское смещение для перемещения объекта из cur_ изометрических координат в dest_ изометрические.
		\param widthHalf Половина ширины тайла - расстояния, по оси X, от западной точки тайла до восточной.
		\param heightHalf Половина высота тайла - расстояния, по оси Y, от северной точки тайла до южной.
		*/
		public static function MoveIso( curX : int, curY : int, destX : int, destY : int, widthHalf : Number, heightHalf : Number) : Point
		{
			const dispX : int = destX - curX;
			const dispY : int = destY - curY;
			
			return new Point(dispX * widthHalf - dispY * widthHalf, dispX * heightHalf + dispY * heightHalf);
		}
		
		/** Разделяем строку с помощью указанного символа и удаляет все пробелу вокруг каждого элемента.*/
		public static function Detach( what : String, delimiter : * ) : Vector.< String >
		{
			var result : Vector.< String > = new Vector.< String >;
			
			var substrings : Array = what.split( delimiter );
			for ( var elementIndex : int = 0; elementIndex < substrings.length; ++elementIndex )
			{
				var element:String = substrings[elementIndex];
				
				for(var left:int = 0; left < element.length; left++)
				{
					if(element.charAt(left) != ' ' && element.charAt(left) != '\n')
					{
						element = element.slice(left);
						break;
					}
				}
				
				for(var right:int = element.length - 1; right >= 0; right--)
				{
					if(element.charAt(right) != ' ' && element.charAt(right) != '\n')
					{
						const startingSpace:int = right + 1;
						if(startingSpace < element.length)
						{
							element = element.slice(0, startingSpace);
						}
						break;
					}
				}
				
				result.push(element);
			}
			
			return result;
		}
		
		public static function RandomShuffle(array:Array): void
		{
			// While there remain elements to shuffle...
			var m:int = array.length;
			while (m)
			{
				// Pick a remaining element... (random value always less then 1):
				const i:int = Math.floor(Math.random() * m--);
				
				// And swap it with the current element.
				const t:* = array[m];
				array[m] = array[i];
				array[i] = t;
			}
		}
		
		private static const ENCODING_SHIFT : int = 13;
		
		/** Make cheating software unable to read specified value.*/
		public static function Encode( value : uint ) : uint
		{
			//rotate left and swap:
			return SwapBytes( ( value << ENCODING_SHIFT ) | ( value >>> ( 32 - ENCODING_SHIFT ) ) );
		}
		
		/** Revert changes made by Encode().*/
		public static function Decode( value : uint ) : uint
		{
			//swap and rotate right:
			const swapped : uint = SwapBytes( value );
			return ( swapped >>> ENCODING_SHIFT ) | ( swapped << ( 32 - ENCODING_SHIFT ) );
		}
		
		/** Смена байт местами для кодирования.*/
		private static function SwapBytes( value : uint ) : uint
		{
			//первый с четвёртым:
			return ( ( value & 0x000000FF ) << 24 ) | ( ( value & 0xFF000000 ) >>> 24 ) |
			//второй с третьим:
			( ( value & 0x0000FF00 ) << 8 ) | ( ( value & 0x00FF0000 ) >>> 8 );
		}
		
		/* Fisher-Yates array shuffle algorithm */
		public static function shuffleArray( array : Array ) : void
		{
			var totalItems : uint = array.length;
			for ( var i : uint = 0; i < totalItems; ++i )
			{
				swap( array, i, i + uint( Math.random() * ( totalItems - i ) ) );
			}
		}
		
		private static function swap( array : Array, a : uint, b : uint ) : void
		{
			var temp : * = array[ a ];
			array[ a ] = array[ b ];
			array[ b ] = temp;
		}
		
		/** Возвращает время проигрывания анимации в сикундах, включая все вложенные элементы.*/
		public static function CalculatePlaySeconds( frameRate : int, movieClip : MovieClip, forRecursionChecking : Vector.< MovieClip > = null ) : Number
		{
			if ( forRecursionChecking == null )
			{
				forRecursionChecking = new Vector.< MovieClip >;
			}
			
			forRecursionChecking.push( movieClip );
			
			var maxSeconds : Number = ( Number ) ( movieClip.totalFrames ) / ( Number ) ( frameRate );
			
			for (var i:int = 0; i < movieClip.numChildren; i++)
			{
				var child:MovieClip = movieClip.getChildAt(i) as MovieClip;
				if (child == null) continue;
				
				for each(var rc:MovieClip in forRecursionChecking)
				{
					if (child == rc)
					{
						Cc.error("E: CalculatePlaySeconds(): recursion detected. Returning currently evaluated seconds.");
						return maxSeconds;
					}
				}
				
				const childSeconds:Number = CalculatePlaySeconds(frameRate, child, forRecursionChecking);
				if (childSeconds > maxSeconds)
				{
					maxSeconds = childSeconds;
				}
			}
			
			return maxSeconds;
		}
		
		/** Возвращает true если проигрывание анимации (включая всех дочерных объектов) завершено.*/
		public static function IsEnded( movieClip : MovieClip, forRecursionChecking : Vector.< MovieClip > = null ) : Boolean
		{
			if ( movieClip.currentFrame < movieClip.totalFrames )
			{
				return false;
			}
			
			if ( forRecursionChecking == null )
			{
				forRecursionChecking = new Vector.< MovieClip >;
			}
			
			forRecursionChecking.push( movieClip );
			
			for ( var i : int = 0; i < movieClip.numChildren; ++i )
			{
				var child : MovieClip = movieClip.getChildAt( i ) as MovieClip;
				if ( child == null )
				{
					continue;
				}
				
				for each( var rc : MovieClip in forRecursionChecking )
				{
					if ( child == rc )
					{
						Cc.error( "E: Utils.IsEnded(): recursion detected. Returning true." );
						return true;
					}
				}
				
				if ( IsEnded( child, forRecursionChecking ) == false )
				{
					return false;
				}
			}
			
			return true;
		}
		
		/** Рекурсивно вызвать указанную функцию для графического объекта и его дочерних.
		\param acceptor function(do:DisplayObject): Boolean должна возвращать true если нужно продолжать итерацию.
		.*/
		public static function ForEachChild(passingDO:DisplayObject, acceptor:Function, forRecursionChecking:Vector.<DisplayObjectContainer> = null): Boolean
		{
			if (!acceptor(passingDO)) return false;
			
			if (forRecursionChecking == null) forRecursionChecking = new Vector.<DisplayObjectContainer>;
			
			var doc:DisplayObjectContainer = passingDO as DisplayObjectContainer;
			if (doc == null) return true;
			
			forRecursionChecking.push(doc);
			
			for (var i:int = 0; i < doc.numChildren; i++)
			{
				var child:DisplayObject = doc.getChildAt(i) as DisplayObject;
				if (child == null) continue;
				
				for each(var rc:DisplayObject in forRecursionChecking)
				{
					if (child == rc)
					{
						Cc.error("E: ForEachChild(): recursion detected. Stopping.");
						return false;
					}
				}
				
				if (!ForEachChild(child, acceptor, forRecursionChecking)) return false;
			}
			
			return true;
		}
		
		/** Возвращает максимальное количество кадров объекта, включая всех его дочерних.*/
		public static function CountFrames(mc:MovieClip): int
		{
			var maxFrames:int = 0;
			
			ForEachChild(mc, function(passingDO:DisplayObject): Boolean
			{
				var passingMC:MovieClip = passingDO as MovieClip;
				if (passingMC != null)
				{
					if (passingMC.totalFrames > maxFrames)
					{
						maxFrames = passingMC.totalFrames;
					}
				}
				return true;
			});
			
			return maxFrames;
		}
		
		/** Возвращает максимальный индекс текущего кадра у объекта, включая всех его дочерних.*/
		public static function CurrentMaxFrame(mc:MovieClip): int
		{
			var currentMaxFrame:int = 0;
			
			ForEachChild(mc, function(passingDO:DisplayObject): Boolean
			{
				var passingMC:MovieClip = passingDO as MovieClip;
				if (passingMC != null)
				{
					if (passingMC.currentFrame > currentMaxFrame)
					{
						currentMaxFrame = passingMC.currentFrame;
					}
				}
				return true;
			});
			
			return currentMaxFrame;
		}
		
		/** Load text from specified URL.
		\param handler function( text:String, ok:Boolean, errorMessage:String ): void - "text" is not-null valid value only if ok is true; "errorMessage" is not-null string only if "ok" is false.
		\param postData POST data to specify within request. If specified, this request will be of type "POST" either "GET".
		*/
		public static function LoadText( url:String, handler:Function, postData:* = null ): void
		{
			var urlLoader:URLLoader = new URLLoader;
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.addEventListener( Event.COMPLETE, function( e:* ): void
			{
				handler( urlLoader.data, true, null );
			} );
			urlLoader.addEventListener( IOErrorEvent.IO_ERROR, function( e:IOErrorEvent ): void
			{
				handler( null, false, e.text );
			} );
			urlLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, function( e:SecurityErrorEvent ): void
			{
				handler( null, false, e.text );
			} );
			var urlRequest:URLRequest = new URLRequest( url );
			if ( postData != null )
			{
				urlRequest.data = postData;
				urlRequest.method = URLRequestMethod.POST;
			}
			urlLoader.load( urlRequest );
		}
		
		/** "where" is a candidate too.*/
		public static function FindParentByType( where : DisplayObject, type : Class ) : DisplayObject
		{
			while ( where != null )
			{
				if ( where is type )
				{
					return where;
				}
				
				where = where.parent;
			}
			return null;
		}
		public static function FindParentByObject( where:DisplayObject, what:DisplayObject ): Boolean
		{
			while ( where != null )
			{
				if ( where == what )
				{
					return true;
				}
				
				if ( where is DisplayObjectContainer )
				{
					where = ( where as DisplayObjectContainer ).parent;
				}
				else
				{
					return false;
				}
			}
			return false;
		}
		
		/** Produces 32-bit hash value from specified key using MurmurHash3 algorytm ( http://code.google.com/p/smhasher/wiki/MurmurHash ).*/
		public static function MurmurHash3 ( key:ByteArray ): uint
		{
			const nblocks:int = key.length / 4;
			
			var h1:uint = 0;
			
			const c1:uint = 0xcc9e2d51;
			const c2:uint = 0x1b873593;
			
			//----------
			// body
			
			for ( var i:int = 0; i < nblocks; ++i )
			{
				const p:int = i * 4;
				var k1:uint = ( key[ p ] ) | ( key[ p + 1 ] << 8 ) | ( key[ p + 2 ] << 16 ) | ( key[ p + 3 ] << 24 );
				
				k1 *= c1;
				k1 = ( k1 << 15 ) | ( k1 >>> ( 32 - 15 ) );
				k1 *= c2;
				
				h1 ^= k1;
				h1 = ( h1 << 13 ) | ( h1 >>> ( 32 - 13 ) );
				h1 = h1 * 5 + 0xe6546b64;
			}
			
			//----------
			// tail
			
			const tail:int = nblocks * 4;
			
			k1 = 0;
			
			switch ( key.length & 3 )
			{
			case 3:
				k1 ^= key[ tail + 2 ] << 16;
			case 2:
				k1 ^= key[ tail + 1 ] << 8;
			case 1:
				k1 ^= key[ tail + 0 ];
				k1 *= c1;
				k1 = ( k1 << 15 ) | ( k1 >>> ( 32 - 15 ) );
				k1 *= c2; h1 ^= k1;
			}
			
			//----------
			// finalization
			
			h1 ^= key.length;
			
			h1 ^= h1 >>> 16;
			//if to use "h1 *= 0x85ebca6b;" then result will differ from C++ version:
			const some1:uint = 0x85ebca6b;
			h1 *= some1;
			h1 ^= h1 >>> 13;
			const some2:uint = 0xc2b2ae35;
			h1 *= some2;
			h1 ^= h1 >>> 16;
			
			return h1;
		}
		
		/** Returns angle which point formes with coordinate system center. Y grows down, X grows right, zero angle is at north and grows clockwise.*/
		public static function PointToRadians( x : Number, y : Number ) : Number
		{
			//"-" because function assumes Y growing up but we growing down:
			const atan2Result : Number = Math.atan2( -y, x );
			
			var result : Number;
			//result grows positively counterclockwise for Y values > 0:
			if ( atan2Result > 0 )
			{
				result = Math.PI * 2.0 - atan2Result;
			}
			//result grows negatively clockwise for Y values < 0:
			else
			{
				result = -atan2Result;
			}
			
			//we assume 0 angle at north:
			result += Math.PI / 2.0;
			return result % ( Math.PI * 2.0 );
		}
		
		public static function Hide( what : DisplayObject ) : void
		{
			if ( what != null && what.parent != null )
			{
				what.parent.removeChild( what );
			}
		}
		
		/** Returns true if two specified tiles are connected to each other (by angle or side).*/
		public static function IsNear( x1 : int, y1 : int, x2 : int, y2 : int ) : Boolean
		{
			const dX : int = Math.abs( x2 - x1 );
			const dY : int = Math.abs( y2 - y1 );
			return (
				( dX <= 1 && dY <= 1 ) &&
				( dX != 0 || dY != 0 )
			);
		}
		
		public static function Distance( x : Number, y : Number ) : Number
		{
			return Math.sqrt( x * x + y * y );
		}
		
		/** To make compiler shut up about conversion, just add " as Vector.< * >" to passing param.*/
		public static function UnifyVector( array : Vector.< * > ) : void
		{
			for ( var i : int = 0; i < array.length; ++i )
			{
				for ( var j : int = i + 1; j < array.length; ++j )
				{
					if ( array[ i ] == array[ j ] )
					{
						array.splice( j, 1 );
						--j;
					}
				}
			}
		}
		
		/** Moves object so that all of it's part fit into the screen (object must be added on stage).*/
		public static function FitScreen( what : DisplayObject ) : void
		{
			if ( what.stage == null )
			{
				return;
			}
			
			var global : Point = what.localToGlobal( new Point );
			//right border:
			global.x = Math.min( global.x, what.stage.stageWidth - what.width );
			//left border:
			global.x = Math.max( global.x, 0 );
			//lower border:
			global.y = Math.min( global.y, what.stage.stageHeight - what.height );
			//upper border:
			global.y = Math.max( global.y, 0 );
			
			var result : Point = what.globalToLocal( global );
			what.x += result.x;
			what.y += result.y;
		}
		
		/** The same as FitScreen but object is moved around mouse pointer instead of just fitting.
		\param left Obligatory gap between object's left or right border and mouse pointer.
		\param up Obligatory gap between object's up or down border and mouse pointer.
		*/
		public static function FitScreenOverMouse( what : DisplayObject, left : Number = 0, up : Number = 0 ) : void
		{
			if ( what.stage == null || what.parent == null )
			{
				return;
			}
			
			var global : Point = what.localToGlobal( new Point );
			//right border:
			if ( global.x + what.width > what.stage.stageWidth )
			{
				global.x = global.x - what.width - left * 2;
			}
			//left border cannot be outbound...
			//lower border:
			if ( global.y + what.height > what.stage.stageHeight )
			{
				global.y = global.y - what.height - up;
			}
			//upper border can be outbound if object positioned slightly higher than mouse pointer:
			if ( global.y < 0 )
			{
				global.y = global.y + up * 2;
			}
			//upper border cannot be outbound...
			
			var result : Point = what.globalToLocal( global );
			what.x += result.x;
			what.y += result.y;
		}
		
		/** Add filters and returns passed object.*/
		public static function MakeGrey( what : DisplayObject ) : DisplayObject
		{
			var b : Number = 1 / 3;
			var c : Number = 1 - ( b * 2 );
			var matrix : Array = [ c, b, b, 0, 0, b, c, b, 0, 0, b, b, c, 0, 0, 0, 0, 0, 1, 0 ];
			what.filters = [ new ColorMatrixFilter( matrix ) ];
			return what;
		}
		
		public static function Print( array : Vector.< int > ) : String
		{
			var result : String = "{ ";
			
			for ( var i : int = 0; i < array.length; ++i )
			{
				if ( i > 0 )
				{
					result = result + ", ";
				}
				
				result = result + array[ i ].toString();
			}
			
			return result + " }";
		}
		
		/** Calculates coordinates for planar movement from dest to target. Movement will end if dest coords are equal to target.
		\param speed Per seconds.
		\param seconds Elapsed from previous call.
		*/
		public static function Move(
			x : Number,
			y : Number,
			targetX : Number,
			targetY : Number,
			speed : Number,
			seconds : Number
		) : Point
		{
			const step : Number = speed * seconds;
			
			const signX : Boolean = x < targetX;
			const signY : Boolean = y < targetY;
			
			const axisX : Number = Math.abs( targetX - x );
			const axisY : Number = Math.abs( targetY - y );
			
			const axesSum : Number = axisX + axisY;
			
			var resultX : Number;
			var resultY : Number;
			
			
			var ended : int = 0;
			
			if ( axisX < step )
			{
				resultX = targetX;
			}
			else
			{
				resultX = x + axisX / axesSum * ( signX ? step : -step );
			}
			
			if ( axisY < step )
			{
				resultY = targetY;
			}
			else
			{
				resultY = y + axisY / axesSum * ( signY ? step : -step );
			}
			
			return new Point( resultX, resultY );
		}
	}

}



