/// @cond
package actions 
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.media.Sound;
	
	/// @endcond
	
	/** Действия, применимые для любых объектов - независимо от типов сущностей.*/
	public class Common 
	{
		/** \brief Ожидание времени.
		\details \anchor Wait
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> Время в секундах, которые нужно прождать.*/
		public static function Wait(param:Param): void
		{
			//Параметры для ожидания:
			/** \brief Сколько нужно ждать секунд.*/
			const A_WAIT:int = 0;
			//Позиции переменных для ожидания:
			/** \brief Сколько ещё осталось прождать.*/
			const D_LEFT:int = 0;
			
			//если это первый цикл выполнения действия:
			if(param.queue.doneCycles <= 0)
			{
				if (Dispatcher.CheckArguments("Wait", param, 1)) return;
				
				//если время, которое нужно прождать, указано неверно:
				if(param.argumentsAsActions[A_WAIT].GetData().AsFloat() <= 0.0)
				{
					//указываем что действие закончилось:
					param.queue.ActionEnded();
					return;
				}
				
				Dispatcher.InitData(param, 1);
				
				//ещё нужно прождать указанное время:
				param.action.data[D_LEFT].ToFloat(param.argumentsAsActions[A_WAIT].GetData().AsFloat());
				
				param.action.output.Out("I: Wait: waiting " + param.argumentsAsActions[A_WAIT].GetData().AsFloat() + " seconds.\n", Output.INFO);
			}
			
			//сколько времени прошло с предыдущего цикла вызова действия:
			const elapsedSeconds:Number = param.action.GetElapsedSeconds();
			
			param.action.output.Out("I: Wait: elapsed " + elapsedSeconds + " seconds.\n", Output.INFO);
			
			//если прошедшего с прошлого цикла времени НЕдостаточно для полного завершения действия ожидания:
			if(param.action.data[D_LEFT].AsFloat() > elapsedSeconds)
			{
				//осталось прождать меньше времени:
				param.action.data[D_LEFT].ToFloat(param.action.data[D_LEFT].AsFloat() - elapsedSeconds);
				//указываем что было потреблено всё время:
				param.action.ConsumedSeconds(elapsedSeconds);
				
				param.action.output.Out("I: Wait: Left to wait " + param.action.data[D_LEFT].AsFloat() + " seconds.\n", Output.INFO);
			}
			//если действие завершилось:
			else
			{
				//потребляем только часть времени - оставшаяся часть может быть использована следующим действием:
				param.action.ConsumedSeconds(param.action.data[D_LEFT].AsFloat());
				//указываем что действие закончилось:
				param.queue.ActionEnded();
				
				param.action.output.Out("I: Wait: Action ended.\n", Output.INFO);
			}
		}
		
		
		/** \brief Переход на указанное действие в указанной очереди.
		\details \anchor GoToAction
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> Внутри какой очереди нужно совершить переход.
		- <span style="color:#ff0000"><b>2</b></span> На какое действие нужно совершить переход в указанной очереди.*/
		public static function GoToAction( param : Param ) : void
		{
			//Параметры для переключения текущего действия:
			/** \brief Идентификатор очереди, текущее действие которой нужно переключить.*/
			const A_QUEUE : int = 0;
			/** \brief На какой индекс переключить текущее действие.*/
			const A_INDEX : int = 1;
			
			if ( Dispatcher.CheckArguments( "GoToAction", param, 2 ) )
			{
				return;
			}
			
			//действие однозначно закончится:
			param.queue.ActionEnded();
			
			const queueId:int = actions.Utils.ToInt(param.argumentsAsActions[A_QUEUE].GetData().AsFloat());
			var obtainedQueue:Queue = param.dispatcher.GetQueue(queueId);
			if (obtainedQueue != null)
			{
				const actionIndex:int = actions.Utils.ToInt(param.argumentsAsActions[A_INDEX].GetData().AsFloat());
				obtainedQueue.GoToAction(actionIndex);
				if (obtainedQueue == param.queue)
				{
					obtainedQueue.SetRemainOnCurrentAction(true);
				}
				return;
			}
			param.action.output.Out("E: GoToAction(): queue with id = " + queueId + " was NOT found.", Output.ERROR);
		}
		
		
		/** \brief Изменение величины с указанными скоростью и ускорением.
		\details \anchor Value_Change
		Основное действие для любых процессов, которые должны изменяться с течением времени.\n
		Действие никакие функции не вызывает. Должно использоваться только для возвращаемого значения.\n
		На каждом этапе окончательная величина высчитывается по формуле:
		\code
		//начальное значение:
		var s0:Number;
		//скорость изменения:
		var v:Number;
		//ускорение:
		var a:Number;
		//сколько времени (в секундах) уже прошло (изначально равно нулю):
		var t:Number;
		//формула подсчёта пройденного пути из физики:
		var s:Number = s0 + v * t + (a * t * t / 2);
		\endcode
		На практике бывает нужно добиться получения какого-либо параметра, задавая остальные. Распространённые случаи:
		<ul type="circle">
		<li> За время <i>t</i> объект должен преодолеть путь <i>S</i>, тогда скорость <i>V</i> = <i>S</i> / <i>t</i>.</li>
		<li> За время <i>t</i> объект должен преодолеть путь <i>S</i> с начальной скоростью <i>V</i>, тогда ускорение <i>a</i> = (2 * (<i>S</i> - <i>V</i> * <i>t</i>)) / (<i>t</i> * <i>t</i>). Если значение <i>V</i> * <i>t</i> больше пути <i>S</i>, то ускорение будет направлено <b>против</b> скорости и объект плавно <i>"пришвартуется"</i> к концу пути (в момент времени <i>t</i>). В противном случае получившееся ускорение либо будет равным нулю (при <i>V</i> * <i>t</i> = <i>S</i> - то есть будет обычное равномерное движение), либо ускорение будет направлено в сторону начальной скорости и объект по истечении времени <i>t</i> продолжит движение в том же направлении, то есть "вылетет" из промежутка <i>S</i>.</li>
		<li> Реалистичное изменение величины достигается двумя последовательными изменениями величины:\n
			- 1 Изменение величины с ускорением, но без начальной скорости.\n
			- 2 Изменение величины с начальной скоростью, равной скорости сформированной в первой половине изменения величины: <i>V2</i> = <i>a1</i> * <i>t1</i>. Ускорение высчитывается как было описано прежде.\n
			В результате, объект будет плавно стартовать и плавно останавливаться.</li>
		<li> Подскоки реализовываются путём многократного изменения величины с начальной скоростью (что обеспечивает подскок - начальная скорость не задаётся если объект изначально падает, а отскок следуюет уже после падения) и ускорением, направленным вниз и равным -9.81 (необходимо спроецировать на пиксели экрана в зависимости от масштаба и перспективы). Каждое последующее изменение величины (действие Value_Change) задаётся с меньшей начальной скоростью (что обеспечивает подскок на меньшую высоту, чем в предыдущем подскоке).</li>
		</ul>
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> Начальное значение (положение).
		- <span style="color:#ff0000"><b>2</b></span> Скорость изменения (единиц в секунду).
		- 3 Ускорение (единиц в секунду за секунду). По-умолчанию равно нулю.
		- 4 Если этот параметр установлен, то действие закончится если окажется равным или переступит это значение (при этом последним значением будет установлено это указанное значение). Если этот параметр равен начальному значению (первый параметр), то действие всё-равно начнёт выполняться.
		- 5 Время, за которое действие предполагается завершиться. Необходимо только для следующего параметра. Если <= 0, то этот и последующий параметры будут игнорироваться. По истечении этого времени (если > 0), выполнение действия остановится.
		- 6 Если этот параметр установлен, то указанный этим параметром аргумент будет выражен через остальные. Путь, необходимый для выражения начального значения, начальной скорости и ускорения, будет высчитан как "конечное значение" (четвёртый аргумент) - "начальное значение" (первый аргумент). Поэтому требуется задание первого аргумента в такое значение, по которому высчитается верный путь. Значения:\n
				<ul type="circle">
				<li> 0 - будет высчитано начальное значение.</li>
				<li> 1 - ... начальная скорость.</li>
				<li> 2 - ... ускорение.</li>
				<li> 3 - ... конечное значение, на котором действие будет считаться завершённым (начальное значение + путь <i>S</i>).</li>
				</ul>
		- 7 Если этот параметр установлен в отличное от нуля значение, то действие <b>НЕ</b> завершится даже если указано конечное значение.*/
		public static function Value_Change( param : Param ) : void
		{
			//Параметры для изменения величины:
			/** \brief Начальное значение (положение).*/
			const A_START_VALUE : int = 0;
			/** \brief Скорость изменения (единиц в секунду).*/
			const A_SPEED : int = 1;
			/** \brief Ускорение (единиц в секунду за секунду).*/
			const A_ACCELERATION : int = 2;
			/** \brief Если этот параметр установлен, то действие закончится если окажется равным или переступит это значение.*/
			const A_TARGET : int = 3;
			/** \brief Время, за которое действие предполагается завершится. Необходимо только для следующего параметра.*/
			const A_TIME : int = 4;
			/** \brief Если этот параметр установлен, то указанный этим параметром аргумент будет выражен через остальные.*/
			const A_EXPRESS : int = 5;
			/** \brief Если этот параметр установлен в отличное от нуля значение, то действие не завершится даже если указано конечное значение.*/
			const A_SUPPRESS_ENDING : int = 6;
			//Позиции переменных для изменения величины:
			/** \brief Сколько уже прошло времени.*/
			const D_ELAPSED_TIME : int = 0;
			/** \brief Предыдыщее установленное значение (для обнаружения завершения действия).*/
			const D_PREVIOUS_VALUE : int = 1;
			
			
			//если это первый цикл выполнения действия:
			if ( param.queue.doneCycles <= 0 )
			{
				if ( Dispatcher.CheckArguments( "Value_Change", param, 2 ) )
				{
					return;
				}
				
				//устанавливаем размер массива данных, используемый только текущим действием:
				Dispatcher.InitData( param, 2 );
				
				//пока ещё не прошло нисколько времени:
				param.action.data[ D_ELAPSED_TIME ].ToFloat( 0.0 );
			}
			
			var elapsedSeconds : Number = param.action.GetElapsedSeconds();
			//обычно действие потребляет всё время, но в случае окончания (зависит от 4-ого параметра) может быть потреблено не всё время:
			var consumedSeconds : Number = elapsedSeconds;
			//увеличиваем прошедшее время:
			const working : Number = param.action.data[ D_ELAPSED_TIME ].AsFloat() + elapsedSeconds;
			param.action.data[ D_ELAPSED_TIME ].ToFloat( working );
			
			//установленные пользователем значения:
			//откуда предполагается начинать изменение величины. Используется и для выражения величин:
			const startValue : Number = param.argumentsAsActions[ A_START_VALUE ].GetData().AsFloat();
			//начальная скорость изменения величины:
			const startSpeed : Number = param.argumentsAsActions[ A_SPEED ].GetData().AsFloat();
			//ускорение:
			const acceleration : Number = param.argumentsAsActions.length > A_ACCELERATION ? param.argumentsAsActions[ A_ACCELERATION ].GetData().AsFloat() : 0.0;
			//где предполагается завершить изменение величины:
			const settledTargetValue : Number = param.argumentsAsActions.length > A_TARGET ? param.argumentsAsActions[ A_TARGET ].GetData().AsFloat() : 0.0;
			
			var ended : Boolean = false;
			
			//величина значения, выраженного через остальные:
			var expressedValue : Number = 0;
			//индекс значения, выраженного через остальные:
			var expressedValueIndex : int = -1;
			//если указано выразить какое-либо значение через остальные:
			if ( param.argumentsAsActions.length > A_EXPRESS )
			{
				//за какое время действие предположительно должно завершиться:
				const time : Number = param.argumentsAsActions[ A_TIME ].GetData().AsFloat();
				if ( time > 0.0 )
				{
					if ( working >= time )
					{
						param.queue.ActionEnded();
						ended = true;
						elapsedSeconds -= working - time;
						consumedSeconds = elapsedSeconds;
					}
					
					//величину под каким индексом нужно выразить:
					const whichValueItsNeedToExpress : int = actions.Utils.ToInt( param.argumentsAsActions[ A_EXPRESS ].GetData().AsFloat() );
					//высчитываем путь, который объект бы преодолел с указанными параметрами:
					const S : Number = settledTargetValue - startValue;
					//выражаем величину, в зависимости от указанного её индекса:
					switch ( whichValueItsNeedToExpress )
					{
						//выражаем начальное значение:
						case 0:
						{
							//выражаем величину:
							expressedValue = S - ( startSpeed * time ) - ( ( acceleration * time * time ) / 2.0 );
							
							//указываем какое значение было выражено:
							expressedValueIndex = 0;
						}
						break;
						
						//выражаем начальную скорость:
						case 1:
						{
							//выражаем величину:
							expressedValue = ( S / time ) - ( acceleration * time / 2.0 );
							
							//указываем какое значение было выражено:
							expressedValueIndex = 1;
						}
						break;
						
						//выражаем ускорение:
						case 2:
						{
							//выражаем величину:
							expressedValue = ( 2.0 * ( S - startSpeed * time ) ) / ( time * time );
							
							//указываем какое значение было выражено:
							expressedValueIndex = 2;
						}
						break;
						
						//выражаем конечное значение:
						case 3:
						{
							//выражаем величину:
							expressedValue = startValue + ( ( startSpeed * time ) + ( ( acceleration * time * time ) / 2.0 ) );
							
							//указываем какое значение было выражено:
							expressedValueIndex = 3;
						}
						break;
					}
				}
			}
			
			//фактические значения, используемые для вычисления величины (могли быть изменены посредством выражения через остальные):
			//начальное значение:
			const s0 : Number  = expressedValueIndex == 0 ? expressedValue : startValue;
			//скорость изменения:
			const v : Number   = expressedValueIndex == 1 ? expressedValue : startSpeed;
			//ускорение:
			const a : Number   = expressedValueIndex == 2 ? expressedValue : acceleration;
			//сколько времени (в секундах) уже прошло (изначально равно нулю):
			const t : Number   = param.action.data[ D_ELAPSED_TIME ].AsFloat();
			//высчитываем текущую величину:
			var value : Number = s0 + v * t + ( a * t * t / 2.0 );
			
			//проверка завершения действия (зависит от 4-ого параметра):
			//если указано значение, при котором действие завершится:
			if ( ended == false && param.argumentsAsActions.length > A_TARGET )
			{
				//если это не подавлено пользователем:
				const suppressEnding : Number = param.argumentsAsActions.length > A_SUPPRESS_ENDING ? param.argumentsAsActions[ A_SUPPRESS_ENDING ].GetData().AsFloat() : 1.0;
				if ( suppressEnding != 0.0 )
				{
					const targetValue : Number = expressedValueIndex == 3 ? expressedValue : settledTargetValue;
					//проверяем не оказалось ли действие равным указанному конечному значению:
					if ( value == targetValue )
					{
						param.action.output.Out( "I: Value_Change(): value reached precisely the target value = " + targetValue + ". Ending.\n", Output.INFO );
						
						//было потреблено всё время (что по-умолчанию), так как действие ровно оказалось на последней "точке"
						param.queue.ActionEnded();
					}
					else
					{
						var previousValue : Number;
						if ( param.queue.doneCycles > 0 )
						{
							previousValue = param.action.data[ D_PREVIOUS_VALUE ].AsFloat();
						}
						//в первом цикле выполнения действия предыдущее значение ещё не установлено:
						else
						{
							previousValue = startValue;
						}
						
						const previousDifference : Number = targetValue - previousValue;
						const currentDifference : Number = targetValue - value;
						//если у разниц отличаются знаки, то значение "перепрыгнуло" через целевое (указанное в 4-ом параметре):
						if ( ( previousDifference < 0 ) != ( currentDifference < 0 ) )
						{
							//разница между текущим значением и предыдущим:
							const differenceBetweenSteps : Number = value - previousValue;
							//действие потребило ту часть времени от прошедшего, какую часть занимает разница между текущим значением и предыдущим от разницы между целевым значением и предыдущим:
							consumedSeconds = elapsedSeconds * Math.abs( ( previousDifference / differenceBetweenSteps ) );
							//устанавливаем значение на указанное конечное:
							value = targetValue;
							//указываем что действие завершилось:
							param.queue.ActionEnded();
							
							param.action.output.Out( "I: Value_Change(): value jumped over the target value = " + targetValue + ". Consumed only " + consumedSeconds + " seconds instead of " + elapsedSeconds + ". Setting value to " + value + " and ending.\n", Output.INFO );
						}
					}
				}
			}
			
			//чтобы в следующем цикле действия можно было его остановить в случае если указан 4-ый параметр и если действие "переступило" или оказалось равным ему:
			param.action.data[ D_PREVIOUS_VALUE ].ToFloat( value );
			
			param.action.output.Out( "I: Value_Change(): setting value to " + value + ".\n", Output.INFO );
			
			//устанавливаем данные для использования действием, которое хранит текущее действие в качестве параметра:
			param.action.SetData( new AbstractData( value ) );
			
			//указываем что было потреблено время:
			param.action.ConsumedSeconds( consumedSeconds );
		}
		
		/** \brief Вызывает функцию один раз и завершается.
		\details \anchor Call
		Параметры:
		- <span style="color:#ff0000"><b>1</b></span> Функция, которую нужно вызвать.
		- 2 Любой параметр, который будет передан в функцию. Если параметр не указан, то функции не будет передано НИЧЕГО.*/
		public static function Call( param : Param ) : void
		{
			if ( Dispatcher.CheckArguments( "Call", param, 1 ) )
			{
				return;
			}
			
			if ( Dispatcher.CastTo( "Call", param, 0, Function ) )
			{
				return;
			}
			
			var toCall : Function = param.argumentsAsActions[ 0 ].GetData().GetData() as Function;
			
			var callingParam : * = null;
			//если есть какой-то параметр для функции:
			if ( param.argumentsAsActions.length > 1 )
			{
				callingParam = param.argumentsAsActions[ 1 ].GetData().GetData();
			}
			
			if ( callingParam == null )
			{
				toCall();
			}
			else
			{
				toCall( callingParam );
			}
			
			param.queue.ActionEnded();
		}
		
		/** \brief Перемещение по кривой Безье.
		\details \anchor Bezier_Move
		Перемещение по указанной кривой за указанное время. Контролируется направление перемещения по кривой.
		- <span style="color:#ff0000"><b>1</b></span> DisplayObject, который двигать по кривой.
		- <span style="color:#ff0000"><b>2</b></span> Указатель на экземпляр класса BezierCurve , который будет использоваться при перемещении кривой.
		- <span style="color:#ff0000"><b>3</b></span> За сколько секунд нужно переместиться от первой точки до последней.
		- 3 Если <b>НЕ</b> равно нулю, то будет контролироваться направление объекта (угол наклона) при перемещении по кривой. По-умолчанию равно нулю.
		- 4 Если третий параметр <b>НЕ</b> равен нулю, то это угол, который считается нулевым углом - по-умолчанию равен нулю.*/
		public static function Bezier_Move( param : Param ) : void
		{
			//Параметры для перемещения по кривой Безье:
			/** \brief Объект, который двигать по кривой.*/
			const A_OBJECT : int = 0;
			/** \brief Указатель на экземпляр класса BezierCurve , который будет использоваться при перемещении кривой.*/
			const A_CURVE : int = 1;
			/** \brief За сколько секунд нужно переместиться от первой точки до последней.*/
			const A_SECONDSTOMOVE : int = 2;
			/** \brief Нужно ли контролировать направление объекта.*/
			const A_ISNEEDTOCONTROLDIRECTION : int = 3;
			/** \brief Нулевой угол.*/
			const A_ZEROANGLE : int = 4;
			//Позиции переменных для перемещения по кривой Безье:
			/** \brief Прошедшее время с момента начала выполнения действия.*/
			const D_ELAPSEDSECONDS : int = 0;
			/** \brief Предыдыщее установленное значение (для обнаружения завершения действия).*/
			const D_PREVIOUSVALUE : int = 1;
			
			if ( Dispatcher.CheckArguments( "Bezier_Move", param, 3 ) )
			{
				return;
			}
			
			if ( Dispatcher.CastTo( "Bezier_Move", param, A_OBJECT, DisplayObject ) )
			{
				return;
			}
			if ( Dispatcher.CastTo( "Bezier_Move", param, A_CURVE, BezierCurve ) )
			{
				return;
			}

			//если это первый цикл выполнения действия:
			if ( param.queue.doneCycles <= 0 )
			{
				//сколько потребуется данных:
				Dispatcher.InitData( param, 2 );
				
				//действие только началось:
				param.action.data[ D_ELAPSEDSECONDS ].ToFloat( 0.0 );
			}
			
			//сколько секунд прошло с момента предыдущего вызова действия:
			const elapsedSeconds : Number = param.action.GetElapsedSeconds();
			//сколько секунд прошло с начала выполнения действия:
			param.action.data[ D_ELAPSEDSECONDS ].ToFloat( param.action.data[ D_ELAPSEDSECONDS ].AsFloat() + elapsedSeconds );
			
			//получение кривой:
			var bezierCurve : BezierCurve = param.argumentsAsActions[ A_CURVE ].GetData().GetData() as BezierCurve;
			
			var object : DisplayObject = param.argumentsAsActions[ A_OBJECT ].GetData().GetData() as DisplayObject;
			
			//вычисление скорости перемещения:
			const speed : Number = 1.0 / param.argumentsAsActions[ A_SECONDSTOMOVE ].GetData().AsFloat();
			//вычисление текущей позиции на кривой:
			var position : Number = param.action.data[ D_ELAPSEDSECONDS ].AsFloat() * speed;
			//настоящая позиция для корректного завершения действия:
			var realPosition : Number = 0.0;
			if ( position >= 1.0 )
			{
				realPosition = position;
				position = 1.0;
			}
			
			
			//получение координат на кривой:
			var point : Point = bezierCurve.GetPosition( position );
			//установка этих координат объекту:
			object.x = point.x;
			object.y = point.y;
			//указан ли параметр слежки за углом направления следования по кривой:
			if ( A_ISNEEDTOCONTROLDIRECTION < param.argumentsAsActions.length )
			{
				//если указано что НУЖНО контролировать направление следования по кривой:
				if(param.argumentsAsActions[A_ISNEEDTOCONTROLDIRECTION].GetData().AsFloat() != 0.0)
				{
					//угол, который считается нулевым:
					var angle:Number = 0.0;
					//если указан какой-то другой угол:
					if(A_ZEROANGLE < param.argumentsAsActions.length)
					{
						angle = param.argumentsAsActions[A_ZEROANGLE].GetData().AsFloat();
					}
					//получаем направление на кривой в указанной точке:
					object.rotation = bezierCurve.GetDirection(position);
				}
			}
			
			
			//сколько секунд было потреблено действием - если действие не закончится, то потребляем всё время:
			var consumedSeconds:Number = elapsedSeconds;
			
			//если действие закончилось:
			if(realPosition >= 1.0)
			{
				const previousPosition:Number = param.action.data[D_PREVIOUSVALUE].AsFloat();
				const previousDifference:Number = 1.0 - previousPosition;
				
				//разница между текущим значением и предыдущим:
				const differenceBetweenSteps:Number = realPosition - previousPosition;
				//действие потребило ту часть времени от прошедшего, какую часть занимает разница между текущим значением и предыдущим от разницы между целевым значением и предыдущим:
				consumedSeconds = elapsedSeconds * Math.abs(previousDifference / differenceBetweenSteps);
				//указываем что действие завершилось:
				param.queue.ActionEnded();
			}
			
			//чтобы в следующем цикле действия можно было его остановить:
			param.action.data[D_PREVIOUSVALUE].ToFloat(realPosition);
			
			//указываем сколько времени потребило действие:
			param.action.ConsumedSeconds(consumedSeconds);
		}

		/** \brief Получение координаты X на кривой Безье.
		\details \anchor Bezier_X
		- <span style="color:#ff0000"><b>1</b></span> Указатель на экземпляр класса BezierCurve , координату на кривой которого нужно получить.
		- <span style="color:#ff0000"><b>2</b></span> Позиция на кривой, где 0 - это позиция первой точки, а 1 - позиция последней точки.*/
		public static function Bezier_X(param:Param): void
		{
			/** \brief Указатель на экземпляр класса BezierCurve , координату на кривой которого нужно получить.*/
			const A_CURVE:int = 0;
			/** \brief Позиция на кривой, где 0 - это позиция первой точки, а 1 - позиция последней точки.*/
			const A_POSITION:int = 1;
			
			if (Dispatcher.CheckArguments("Bezier_X", param, 2)) return;
			if (Dispatcher.CastTo("Bezier_X", param, A_CURVE, BezierCurve)) return;
			
			//получение кривой:
			var bezierCurve:BezierCurve = param.argumentsAsActions[A_CURVE].GetData().GetData() as BezierCurve;
			//получение позиции на кривой:
			const position:Number = param.argumentsAsActions[A_POSITION].GetData().AsFloat();
			//получение координат на кривой:
			var point:Point = bezierCurve.GetPosition(position);
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(point.x));
			
			//действие однозначно заканчивается:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение координаты Y на кривой Безье.
		\details \anchor Bezier_Y
		- <span style="color:#ff0000"><b>1</b></span> Указатель на экземпляр класса BezierCurve , координату на кривой которого нужно получить.
		- <span style="color:#ff0000"><b>2</b></span> Позиция на кривой, где 0 - это позиция первой точки, а 1 - позиция последней точки.*/
		public static function Bezier_Y(param:Param): void
		{
			/** \brief Указатель на экземпляр класса BezierCurve , координату на кривой которого нужно получить.*/
			const A_CURVE:int = 0;
			/** \brief Позиция на кривой, где 0 - это позиция первой точки, а 1 - позиция последней точки.*/
			const A_POSITION:int = 1;
			
			
			if (Dispatcher.CheckArguments("Bezier_Y", param, 2)) return;
			if (Dispatcher.CastTo("Bezier_Y", param, A_CURVE, BezierCurve)) return;
			
			//получение кривой:
			var bezierCurve:BezierCurve = param.argumentsAsActions[A_CURVE].GetData().GetData() as BezierCurve;
			//получение позиции на кривой:
			const position:Number = param.argumentsAsActions[A_POSITION].GetData().AsFloat();
			//получение координат на кривой:
			var point:Point = bezierCurve.GetPosition(position);
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(point.y));
			
			//действие однозначно заканчивается:
			param.queue.ActionEnded();
		}
		
		/** \brief Получение направления кривой Безье в указанной её точке.
		\details \anchor Bezier_Direction
		Углы измеряются <b>в градусах</b>. Угол разворачивается <b>по часовой стрелке</b>.
		- <span style="color:#ff0000"><b>1</b></span> Указатель на экземпляр класса BezierCurve , направление которой нужно получить.
		- <span style="color:#ff0000"><b>2</b></span> Позиция на кривой, где 0 - это позиция первой точки, а 1 - позиция последней точки.*/
		public static function Bezier_Direction(param:Param): void
		{
			/** \brief Указатель на экземпляр класса BezierCurve , направление которой нужно получить.*/
			const A_CURVE:int = 0;
			/** \brief Позиция на кривой, где 0 - это позиция первой точки, а 1 - позиция последней точки.*/
			const A_POSITION:int = 1;
			
			
			if (Dispatcher.CheckArguments("Bezier_Direction", param, 2)) return;
			if (Dispatcher.CastTo("Bezier_Direction", param, A_CURVE, BezierCurve)) return;
			
			//получение кривой:
			var bezierCurve:BezierCurve = param.argumentsAsActions[A_CURVE].GetData().GetData() as BezierCurve;
			//получение позиции на кривой:
			const position:Number = param.argumentsAsActions[A_POSITION].GetData().AsFloat();
			//получение направления кривой в указанной точке:
			var direction:Number = bezierCurve.GetDirection(position);
			
			//устанавливаем данные для использование действием, которые хранит текущее действие в качестве параметра:
			param.action.SetData(new AbstractData(direction));
			
			//действие однозначно заканчивается:
			param.queue.ActionEnded();
		}
		
		/** \brief Playing single sound.
		\details \anchor Sound_Play
		- <span style="color:#ff0000"><b>1</b></span> Sound object to call play() for.*/
		public static function Sound_Play( param : Param ) : void
		{
			/** \brief Sound class instance.*/
			const A_SOUND : int = 0;
			
			
			if ( Dispatcher.CheckArguments( "Sound_Play", param, 1 ) )
			{
				return;
			}
			if ( Dispatcher.CastTo( "Sound_Play", param, A_SOUND, Sound ) )
			{
				return;
			}
			
			//obtaining sound:
			var sound : Sound = param.argumentsAsActions[ A_SOUND ].GetData().GetData() as Sound;
			
			//actually playing obtained sound:
			sound.play();
			
			//action is unabiguously ended:
			param.queue.ActionEnded();
		}
		
	}

}



