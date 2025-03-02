/// @cond
package actions 
{
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	/// @endcond
	
	public class Graphical 
	{
		/** \brief Установка уровня прозрачности.
		\details \anchor Alpha_Set
		- <b>1</b> DisplayObject: у какого объекта изменять прозрачность.
		- <b>2</b> Вызывает функцию DisplayObject.alpha set с указанным параметром.*/
		public static function Alpha_Set(param:Param): void
		{
			if ( Dispatcher.CheckArguments( "Alpha_Set", param, 2 ) )
			{
				return;
			}
			
			if ( Dispatcher.CastTo( "Alpha_Set", param, 0, DisplayObject ) )
			{
				return;
			}
			
			//устанавливаем прозрачность:
			var displayObject : DisplayObject = param.argumentsAsActions[ 0 ].GetData().GetData() as DisplayObject;
			displayObject.alpha = param.argumentsAsActions[ 1 ].GetData().AsFloat();
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение текущего уровня прозрачности.
		\details \anchor Alpha_Get
		- <b>1</b> DisplayObject: у какого объекта получать прозрачность.
		<b>Устанавливает состояние в</b>: результат вызова функции DisplayObject.alpha get .*/
		public static function Alpha_Get(param:Param): void
		{
			if (Dispatcher.CheckArguments("Alpha_Get", param, 1)) return;
			
			if (Dispatcher.CastTo("Alpha_Get", param, 0, DisplayObject)) return;
			
			var displayObject:DisplayObject = param.action.data[0].GetData().GetData() as DisplayObject;
			
			param.action.SetData(new AbstractData(displayObject.alpha));
			
			param.queue.ActionEnded();
		}
		
		/** \brief Плавное изменение прозрачности от одного значения до другого за указанное время.
		\details \anchor Alpha_Change
		Прозрачность будет изменяться ровно столько времени, сколько указано в параметрах действия, даже если начальная и конечная прозрачности указаны равными. Поэтому, если параллельно также происходит изменение прозрачности, то конечный эффект будет суммарным.\n
		Параметры "начальная" и "конечная" прозрачности могут использоваться для формирования <b>направления</b> и величины изменения прозрачности. Например, если указать "изменить со 100 до 150", а при этом прозрачность равна 0, то она увеличится с 0 до 50. Для использования этого варианта см. 5-ый параметр.\n
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject Объект, прозрачность которого нужно изменять.
		- <span style="color:#ff0000"><b>2</b></span> Время в секундах, за которое нужно изменить прозрачность. Если число отрицательное, то это скорость изменения единиц прозрачности в секунду.
		- <span style="color:#ff0000"><b>3</b></span> Изначальная прозрачность, с которой нужно начинать плавное изменение прозрачности. -1 - будет взята текущая прозрачность, что эквивалетно \ref Alpha_Get .
		- <span style="color:#ff0000"><b>4</b></span> Конечная прозрачность, на которой нужно остановить плавное изменение прозрачности.
		- 5 Устанавливать ли начальную и конечную прозрачности. В случае игнорирования или неверно заданного значения расценивается как 0. Возможные значения:\n
				<ul type="circle">
				<li> 0 - начальная прозрачность будет установлена в первом цикле выполнения действия, конечная - в последнем. По-умолчанию.</li>
				<li> 1 - начальная прозрачность будет установлена в первом цикле выполнения действия. Конечная прозрачность установлена <b>НЕ</b> будет.</li>
				<li> 2 - начальная прозрачность устанавливаться <b>НЕ</b> будет. Конечная прозрачность будет установлена в последнем цикле.</li>
				<li> 3 - Ни начальная, ни конечная прозрачности устанавливаться <b>НЕ</b> будут.</li>
				</ul>
		*/
		public static function Alpha_Change( param : Param ) : void
		{
			//Параметры для плавного изменения прозрачности:
			/** Объект с которым работать.*/
			const A_OBJECT : int = 0;
			/** \brief Время в секундах, за которое нужно изменить прозрачность. Если число отрицательное, то это скорость изменения единиц прозрачности в секунду.*/
			const A_TIME:int = 1;
			/** \brief Изначальная прозрачность.*/
			const A_START_ALPHA:int = 2;
			/** \brief Конечная прозрачность.*/
			const A_END_ALPHA:int = 3;
			/** \brief Если НЕ ноль, то в первом цикле выполнения действия будет установлена изначальная прозрачность.*/
			const A_SET_ALPHA:int = 4;
			//Позиции переменных для плавного изменения прозрачности:
			/** \brief За сколько секунд нужно изменить прозрачность.*/
			const D_TIME_TO_CHANGE:int = 0;
			/** \brief Скорость изменения прозрачность "единиц в секунду".*/
			const D_SPEED:int = 1;
			/** \brief Сколько секунд уже изменяется прозрачность.*/
			const D_ELAPSED_TIME:int = 2;
			/** \brief Если НЕ ноль, то в первом цикле выполнения действия будет установлена изначальная прозрачность.*/
			const D_SET_ALPHA:int = 3;
			/** \brief Почему-то маленькие значения не сохраняются в object.alpha */
			const D_CURRENT_ALPHA:int = 4;
			
			
			if ( Dispatcher.CastTo( "Alpha_Change", param, A_OBJECT, DisplayObject ) )
			{
				return;
			}
			
			var object : DisplayObject = param.argumentsAsActions[ A_OBJECT ].GetData().GetData() as DisplayObject;
			
			//если это первый цикл выполнения действия:
			if ( param.queue.doneCycles <= 0 )
			{
				if ( Dispatcher.CheckArguments( "Alpha_Change", param, 4 ) )
				{
					return;
				}
				
				//устанавливаем размер массива данных, используемый только текущим действием:
				Dispatcher.InitData( param, 5 );
				
				var startAlpha : Number = param.argumentsAsActions[ A_START_ALPHA ].GetData().AsFloat();
				if ( actions.Utils.ToInt( startAlpha ) == -1 )
				{
					startAlpha = object.alpha;
				}
				param.action.data[ D_CURRENT_ALPHA ].ToFloat( startAlpha );
				
				var endAlpha:Number = param.argumentsAsActions[ A_END_ALPHA ].GetData().AsFloat();
				
				//5-ый параметр (пока по-умолчанию):
				var setAlpha : int = 0;
				//если он установлен пользователем:
				if(param.argumentsAsActions.length >= 5)
				{
					setAlpha = actions.Utils.ToInt(param.argumentsAsActions[A_SET_ALPHA].GetData().AsFloat());
					if(setAlpha < 0 || setAlpha > 3)
					{
						param.action.output.Out("W: Alpha_Change(): fifth arguments = " + setAlpha + " is wrong. It will be evaluated as 0.\n", Output.WARN);
						setAlpha = 0;
					}
				}
				//сохраняем 5-ый параметр:
				param.action.data[D_SET_ALPHA].ToFloat(setAlpha);
				//устанавливаем начальную прозрачность, если обратное не оговорено в 5-ом параметре:
				if(setAlpha == 0 || setAlpha == 1)
				{
					object.alpha = startAlpha;
				}
				
				
				//сколько секунд нужно изменять прозрачность:
				var secondsToChange:Number = param.argumentsAsActions[A_TIME].GetData().AsFloat();
				//если прозрачность нужно изменить "мгновенно":
				if(secondsToChange == 0.0)
				{
					param.action.output.Out("W: Alpha_Change(): time to change = 0. Nothing will be done.\n", Output.WARN);
					
					//устанавливаем конечную прозрачность, если обратное не оговорено в 5-ом параметре:
					if(setAlpha == 0 || setAlpha == 2)
					{
						object.alpha = param.argumentsAsActions[A_END_ALPHA].GetData().AsFloat();
					}
					
					//указываем что действие закончилось:
					param.queue.ActionEnded();
					return;
				}
				//скорость изменения прозрачности:
				var speed:Number;
				//устанавливаем шаг изменения прозрачности на каждую миллисекунду если было указано время, за которое эту прозрачность нужно изменить:
				if(secondsToChange > 0.0)
				{
					speed = (endAlpha - startAlpha) / secondsToChange;
				}
				//в противном случае скорость задана конкретно:
				else
				{
					speed = -secondsToChange;
					//высчитываем сколько секунд потребуется для изменения прозрачности:
					secondsToChange	= Math.abs((endAlpha - startAlpha) / speed);
				}
				//устанавливаем направление скорости в зависимости от направления изменения прозрачности:
				if(endAlpha < startAlpha)
				{
					speed = -Math.abs(speed);
				}
				else if(actions.Utils.IsEqual(endAlpha, startAlpha))
				{
					speed = 0.0;
				}
				param.action.output.Out("I: Alpha_Change(): action will consume " + secondsToChange + " seconds to change alpha from " + startAlpha + " to " + endAlpha + " with speed = " + speed + ".\n", Output.INFO);
				param.action.data[D_TIME_TO_CHANGE].ToFloat(secondsToChange);
				param.action.data[D_SPEED].ToFloat(speed);
				
				//изначально нет пройденного времени:
				param.action.data[D_ELAPSED_TIME].ToFloat(0.0);
			}
			
			//сколько ещё осталось времени:
			var leftSeconds:Number = param.action.data[D_TIME_TO_CHANGE].AsFloat() - param.action.data[D_ELAPSED_TIME].AsFloat();
			//сколькими секундами мы располагаем в этом цикле:
			var haveSeconds:Number = param.action.GetElapsedSeconds();
			//закончилось ли действие:
			var isEnd:Boolean = false;
			//если действие закончилось:
			if(haveSeconds >= leftSeconds)
			{
				//выполняем действие на всё время что осталось до его полного завершения:
				haveSeconds = leftSeconds;
				//отмечаем что действие завершилось:
				isEnd = true;
			}
			//на сколько будет изменена прозрачность:
			var alphaChange:Number = haveSeconds * param.action.data[D_SPEED].AsFloat();
			//новая величина прозрачности:
			const nextAlpha:Number = param.action.data[D_CURRENT_ALPHA].AsFloat() + alphaChange;
			param.action.data[D_CURRENT_ALPHA].ToFloat(nextAlpha);
			param.action.output.Out("I: Alpha_Change(): alpha will be settled to " + nextAlpha + ". alphaChange = " + alphaChange + ", leftSeconds = " + leftSeconds + "\n", Output.INFO);
			//устанавливаем новую прозрачность:
			object.alpha = nextAlpha;
			
			param.action.ConsumedSeconds(haveSeconds);
			
			if(isEnd)
			{
				const destAlpha:int = actions.Utils.ToInt(param.action.data[D_SET_ALPHA].AsFloat());
				//устанавливаем конечную прозрачность, если обратное не оговорено в 5-ом параметре:
				if(destAlpha == 0 || destAlpha == 2)
				{
					object.alpha = param.argumentsAsActions[A_END_ALPHA].GetData().AsFloat();
				}
				
				//указываем что действие закончилось:
				param.queue.ActionEnded();
				return;
			}
			
			//увеличиваем общее использованное время на время, потраченное в текущем цикле:
			param.action.data[D_ELAPSED_TIME].ToFloat(param.action.data[D_ELAPSED_TIME].AsFloat() + haveSeconds);
		}
		
		/** \brief Установка масштаба картинки.
		\details \anchor Scale_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		- <span style="color:#ff0000"><b>2</b></span> X
		- <span style="color:#ff0000"><b>3</b></span> Y */
		public static function Scale_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("Scale_Set", param, 3)) return;
			
			if (Dispatcher.CastTo("Scale_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			object.scaleX = param.argumentsAsActions[1].GetData().AsFloat();
			object.scaleY = param.argumentsAsActions[2].GetData().AsFloat();
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Установка масштаба картинки.
		\details \anchor Scale_X_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		- <span style="color:#ff0000"><b>2</b></span> X */
		public static function Scale_X_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("Scale_X_Set", param, 2)) return;
			
			if (Dispatcher.CastTo("Scale_X_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			object.scaleX = param.argumentsAsActions[1].GetData().AsFloat();
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Установка масштаба картинки.
		\details \anchor Scale_Y_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		- <span style="color:#ff0000"><b>2</b></span> Y */
		public static function Scale_Y_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("Scale_Y_Set", param, 2)) return;
			
			if (Dispatcher.CastTo("Scale_Y_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			object.scaleY = param.argumentsAsActions[1].GetData().AsFloat();
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение масштаба картинки.
		\details \anchor Scale_X_Get
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		<b>Устанавливает состояние в</b>: масштаб по оси X .*/
		public static function Scale_X_Get(param:Param): void
		{
			if (Dispatcher.CheckArguments("Scale_X_Get", param, 1)) return;
			
			if (Dispatcher.CastTo("Scale_X_Get", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(object.scaleX));
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение масштаба картинки.
		\details \anchor Scale_Y_Get
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		<b>Устанавливает состояние в</b>: масштаб по оси Y .*/
		public static function Scale_Y_Get(param:Param): void
		{
			if (Dispatcher.CheckArguments("Scale_Y_Get", param, 1)) return;
			
			if (Dispatcher.CastTo("Scale_Y_Get", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(object.scaleY));
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Показ картинки.
		\details \anchor Show
		Делает объект видимым: DisplayObject.visible = true;
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.*/
		public static function Show(param:Param): void
		{
			if ( Dispatcher.CheckArguments( "Show", param, 1 ) )
			{
				return;
			}
			
			if ( Dispatcher.CastTo( "Show", param, 0, DisplayObject ) )
			{
				return;
			}
			
			var object : DisplayObject = param.argumentsAsActions[ 0 ].GetData().GetData() as DisplayObject;
			
			object.visible = true;
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Скрытие картинки.
		\details \anchor Hide
		Скрывает объект.
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.*/
		public static function Hide(param:Param): void
		{
			if (Dispatcher.CheckArguments("Hide", param, 1)) return;
			
			if (Dispatcher.CastTo("Hide", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			object.visible = false;
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Fully removes picture from display list.
		\defailt \anchor Disappear
		Params:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: which object will be removed.*/
		public static function Disappear( param : Param ) : void
		{
			if ( Dispatcher.CheckArguments( "Disappear", param, 1 ) )
			{
				return;
			}
			
			if ( Dispatcher.CastTo( "Disappear", param, 0, DisplayObject ) )
			{
				return;
			}
			
			var object : DisplayObject = param.argumentsAsActions[ 0 ].GetData().GetData() as DisplayObject;
			
			if ( object.parent != null )
			{
				object.parent.removeChild( object );
			}
			
			param.queue.ActionEnded();
		}
		
		/** \brief Установка координаты X.
		\details \anchor Coord_X_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		- <span style="color:#ff0000"><b>2</b></span> Координата X, которую нужно установить.*/
		public static function Coord_X_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("Coord_X_Set", param, 2)) return;
			
			if (Dispatcher.CastTo("Coord_X_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			object.x = param.argumentsAsActions[1].GetData().AsFloat();
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Установка координаты Y.
		\details \anchor Coord_Y_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		- <span style="color:#ff0000"><b>2</b></span> Координата Y, которую нужно установить.*/
		public static function Coord_Y_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("Coord_Y_Set", param, 2)) return;
			
			if (Dispatcher.CastTo("Coord_Y_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			object.y = param.argumentsAsActions[1].GetData().AsFloat();
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Установка координаты X и Y.
		\details \anchor Coord_X_Y_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.
		- <span style="color:#ff0000"><b>2</b></span> Координата X, которую нужно установить.
		- <span style="color:#ff0000"><b>3</b></span> Координата Y, которую нужно установить.*/
		public static function Coord_X_Y_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("Coord_X_Y_Set", param, 3)) return;
			
			if (Dispatcher.CastTo("Coord_X_Y_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			object.x = param.argumentsAsActions[1].GetData().AsFloat();
			object.y = param.argumentsAsActions[2].GetData().AsFloat();
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение координаты X.
		\details \anchor Coord_X_Get
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.*/
		public static function Coord_X_Get(param:Param): void
		{
			if (Dispatcher.CheckArguments("Coord_X_Get", param, 1)) return;
			
			if (Dispatcher.CastTo("Coord_X_Get", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(object.x));
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение координаты Y.
		\details \anchor Coord_Y_Get
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject: с каким объектом работать.*/
		public static function Coord_Y_Get(param:Param): void
		{
			if (Dispatcher.CheckArguments("Coord_Y_Get", param, 1)) return;
			
			if (Dispatcher.CastTo("Coord_Y_Get", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(object.y));
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Установка угла вращения по оси Z.
		\details \anchor Angle_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> Угол вращения по оси Z <b>в градусах</b>.*/
		public static function Angle_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("Angle_Set", param, 2)) return;
			
			if (Dispatcher.CastTo("Angle_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			const angle:Number = param.argumentsAsActions[1].GetData().AsFloat();
			
			object.rotation = angle;
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение угла вращения по оси Z.
		\details \anchor Angle_Get */
		public static function Angle_Get(param:Param): void
		{
			if (Dispatcher.CheckArguments("Angle_Get", param, 0)) return;
			
			if (Dispatcher.CastTo("Angle_Get", param, 0, DisplayObject)) return;
			
			var object:DisplayObject = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(object.rotation));
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Установить фильтр свечения. (см. <a href="http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/filters/GlowFilter.html">документацию flash'а</a>)
		\details \anchor GlowFilter_Set
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> Графический объект, которому присвоить фильтр. DisplayObject.
		- <span style="color:#ff0000"><b>2</b></span> The color of the glow. uint. uint.
		- <span style="color:#ff0000"><b>3</b></span> The alpha transparency value for the color. Number.
		- <span style="color:#ff0000"><b>4</b></span> The amount of horizontal blur. Number.
		- <span style="color:#ff0000"><b>5</b></span> The amount of vertical blur. Number.
		- <span style="color:#ff0000"><b>6</b></span> The strength of the imprint or spread. Number.
		- <span style="color:#ff0000"><b>7</b></span> The number of times to apply the filter. int.
		- <span style="color:#ff0000"><b>8</b></span> Specifies whether the glow is an inner glow. Boolean.
		- <span style="color:#ff0000"><b>9</b></span> Specifies whether the object has a knockout effect. Boolean.
		.*/
		public static function GlowFilter_Set(param:Param): void
		{
			if (Dispatcher.CheckArguments("GlowFilter_Set", param, 9)) return;
			
			if (Dispatcher.CastTo("GlowFilter_Set", param, 0, DisplayObject)) return;
			
			var object:DisplayObject  = param.argumentsAsActions[0].GetData().GetData() as DisplayObject;
			const color:uint          = param.argumentsAsActions[1].GetData().GetData() as uint;
			const alpha:Number        = param.argumentsAsActions[2].GetData().GetData() as Number;
			const blurX:Number        = param.argumentsAsActions[3].GetData().GetData() as Number;
			const blurY:Number        = param.argumentsAsActions[4].GetData().GetData() as Number;
			const strength:Number     = param.argumentsAsActions[5].GetData().GetData() as Number;
			const quality:int         = param.argumentsAsActions[6].GetData().GetData() as int;
			const inner:Boolean       = param.argumentsAsActions[7].GetData().GetData() as Boolean;
			const knockout:Boolean    = param.argumentsAsActions[8].GetData().GetData() as Boolean;
			
			object.filters = [new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout)];
			
			//указываем что действие закончилось:
			param.queue.ActionEnded();
		}
		
		/** \brief Specify TextField's text based on passed value.
		\details \anchor Text_Set
		Params:
		- <span style="color:#ff0000"><b>1</b></span> TextField .text attribute of which will be settled.
		- <span style="color:#ff0000"><b>2</b></span> Any data "toString()" for which will be used as setting text.
		- 3 function( firstParam : TextField, secondParam : String ) : void Function which is called instead text applying if specified.
		.*/
		public static function Text_Set( param : Param ) : void
		{
			if ( Dispatcher.CheckArguments( "Text_Set", param, 2 ) )
			{
				return;
			}
			
			if ( Dispatcher.CastTo( "Text_Set", param, 0, TextField ) )
			{
				return;
			}
			
			var textField : TextField = param.argumentsAsActions[ 0 ].GetData().GetData() as TextField;
			
			var data : * = param.argumentsAsActions[ 1 ].GetData().GetData();
			
			var applyingFunction : Function = null;
			if ( param.argumentsAsActions.length > 2 )
			{
				applyingFunction = param.argumentsAsActions[ 2 ].GetData().GetData() as Function;
			}
			
			if ( applyingFunction == null )
			{
				textField.text = data.toString();
			}
			else
			{
				try
				{
					applyingFunction( textField, data.toString() );
				}
				catch ( e : Error )
				{
					Cc.error( "E: Graphical.Text_Set(): call to applying function failed with \"" + e.message + "\"." );
				}
			}
			
			param.queue.ActionEnded();
		}
	}

}