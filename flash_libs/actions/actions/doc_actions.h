/** \file
\brief Файл документации для композиции классов "Actions" ( actions.h ).*/



/** \mainpage
Набор классов и структур "Actions" для формирования очередей действий для картинок, анимаций, звуков и так далее.\n
Использование схоже с установкой объектам сценария <i>что делать</i>, после чего этот сценарий выполняется (обычно в параллельном потоке).

См. страницу описания \ref Using_actions */

/** \page Using_actions Использование "Actions".
\brief Действия, которые могут формировать очередь и выполняться параллельно в разных очередях.

\section Examples Примеры
Действия могут быть ожиданием, плавным появлением, перемещением и т.д.\n

\subsection One_action Одно действие
Пример плавного появления картинки:\n
\code
public class Main
{
	private var lastTimer:int = 0;
	
	public var image:Sprite = new Sprite;
	
	private var output:Output = new Output(function(what:String, type:int): void
	{
		trace(what);
	});
	
	public var dispatcher:Dispatcher = new Dispatcher(output);
	
	public function Main()
	{
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		image.graphics.clear();
		image.graphics.beginFill(0xff0000);
		image.graphics.drawRect(0, 0, 30, 30);
		image.graphics.endFill();
		addChild(image);
		
		lastTimer = getTimer();
		
		var alphaChange:ActionDesc = new ActionDesc(output);
		alphaChange.To(Graphical.Alpha_Change, image, 100, 0, 1, 1);
		dispatcher.CreateAction( -1, alphaChange);
	}
	
	private function onEnterFrame(e:Event): void
	{
		const currentTimer:int = getTimer();
		const elapsedSeconds:Number = (Number)(currentTimer - lastTimer) / 1000.0;
		lastTimer = currentTimer;
		
		dispatcher.Live(elapsedSeconds);
	}
}
\endcode
В остальных примерах отброшен код конкретного использования и показаны только задевающие тему вопроса строки.

\subsection Actions_in_queue Действия внутри очереди
Каждое созданное действие существует в очереди. После завершения выполнения текущего действия в очереди, начинает выполняться следующее действие.\n
Пример исчезновения картинки после появления:\n
\code
//картинка плавно появится, прождёт секунду и плавно исчезнет:
var alphaChange:ActionDesc = new ActionDesc(output);
alphaChange.To(Graphical.Alpha_Change, image, 0.800, 1, 0, 1);
dispatcher.CreateAction(0, alphaChange);
alphaChange.To(Graphical.Alpha_Change, image, 0.800, 0, 1, 1);
dispatcher.CreateAction(0, alphaChange);
\endcode
Чтобы запретить действию заканчиваться нужно указать ActionDesc.muteEnding = true .

\subsection Action_as_argument Действие как аргумент другого действия.
Каждое действие является функцией, способной получать параметры из других действий. Действия реализованы так, что расценивают свои параметры как константные параметры, поэтому завершаются тогда, когда считают нужным. Для избежания этого применяется функция Actions::ActionDesc::SetMuteEnding (true) .\n
Пример:
\code
//изменение масштаба с нуля до 20:
dispatcher.Clear();
var actionDesc_ValueChange:ActionDesc = new ActionDesc(output);
actionDesc_ValueChange.To(Common.Value_Change, 0.0, 1.0, 0.0, 20.0);
var actionDesc:ActionDesc = new ActionDesc(output);
actionDesc.To(Graphical.Scale_Set, image, actionDesc_ValueChange, actionDesc_ValueChange);
//действие Graphical.Scale_Set выполняется за один цикл, поэтому чтобы оно не заканчивалось, пока не закончится действие Common.Value_Change :
actionDesc.muteEnding = true;
dispatcher.CreateAction(0, actionDesc);
\endcode

\subsection Parallel_actions Параллельное выполнение действий.
Различные действия могут выполняться параллельно в разных очередях.\n
Параллельное изменение масштаба картинки в процессе появления и исчезновения:\n
\code
//плавное появление картинки из прозрачности и с увеличивающимся масштабом и такое же исчезновение спустя 1 секунду:
var alphaChange:ActionDesc = new ActionDesc(output);
alphaChange.To(Graphical.Alpha_Change, image, 0.800, 1, 0, 1);
dispatcher.CreateAction(0, alphaChange);
alphaChange.To(Graphical.Alpha_Change, image, 0.800, 0, 1, 1);
dispatcher.CreateAction(0, alphaChange);

var actionDesc_ValueChange:ActionDesc = new ActionDesc(output);
actionDesc_ValueChange.To(Common.Value_Change, 0.0, 1.25, 0.0, 1.0);
var actionDesc:ActionDesc = new ActionDesc(output);
actionDesc.To(Graphical.Scale_Set, image, actionDesc_ValueChange, actionDesc_ValueChange);
actionDesc.muteEnding = true;
dispatcher.CreateAction(1, actionDesc);
actionDesc.To(Common.Wait, 1);
dispatcher.CreateAction(1, actionDesc);
actionDesc_ValueChange.To(Common.Value_Change, 1.0, -1.25, 0.0, 0.0);
actionDesc.To(Graphical.Scale_Set, image, actionDesc_ValueChange, actionDesc_ValueChange);
actionDesc.muteEnding = true;
dispatcher.CreateAction(1, actionDesc);
\endcode


Полный список действий см. на странице \ref Available_actions .\n

При добавлении в очередь действия оно выполняется по-шагово в Actions::Dispatcher::Live() . По окончании выполнения действия оно продолжает оставаться в очереди, но уже не выполняется. Добавление в очередь нового действия не прерывает выполнения других действий в этой очереди. Если в очереди выполнение всех действий закончилось, то выполнение возобновляется с только что добавленного действия.

\section Actions Действия.
Каждое действие представляет из себя функцию, которая вызывается с фиксированными параметрами ( Actions::ACTION_ARGUMENTS - диспетчер, очередь, само действие, вектор параметров действия).\n
Параметрами действия могут быть простые вещественные числа, другие действия и любые данные ( Actions::AbstractData ). В случае если параметром действия является другое действие, то в качестве параметра используется устанавливаемое действием значение (посредством Actions::Action::SetData() ). Например действие \ref Coord_X_Set можно сформировать с простым числом (например 5 - тогда координата X будет просто установлена в 5), а можно сформировать с действием \ref Value_Change , в котором координата будет изменяться с указанной скоростью и ускорением. В свою очередь, в параметр параметра \ref Value_Change можно также передать действие, тогда, например, можно сделать изменяющимся ускорение. Уровень вложенности не ограничен.

\section Writing_your_own_actions Добавление новых действий.
Выполнение действия будет вызываться в Actions::Dispatcher::Live() до тех пор, пока оно либо не потребит всё время, либо не укажет что оно закончилось. При этом сохранённым будет то значение (оно будет использоваться в действии, которое хранит текущее действие как параметр), которое было указано в последнем цикле выполнения действия.\n

\section Etcetera Прочее.
- Процесс добавления 1500 действий ValueChange по-одному действию в одну очередь занимает 5.154003 секунд (на Intel(R) Pentium(R) @ 1.60GHz). Один вызов Live(0.020f) у получившегося объекта занимает 0.003162 секунды. Те же данные при добавлении только одного действия: 0.000019 и 0.000004 секунды.



\page Available_actions Доступные типы действий.
Перечислены доступные типы действий с кратким описанием оных.\n
Параметры действий, выделенные <span style="color:#ff0000"><b>красным</b></span> цветом, обязательны. Остальные параметры можно не узазывать.
\n

\section Core_actions Действия для работы с самой архитектурой Actions.
\ref Wait - Ожидание времени.\n
\ref WaitTillActionsEnded - Ожидание выполнения действий в очереди объекта.\n
\ref WaitTillSoundStop - Ожидание завершения проигрывания звука.\n
\ref GoToAction - Переход на указанное действие в указанной очереди.\n
\ref TernaryOperator - Установка результата выполнения действия в зависимости от параметра.\n
\ref Data_Set - Установка данных в диспетчере или в очереди.\n
\ref Data_Get - Получение данных из диспетчера или из очереди.\n
\ref Clear - Очистка очередей.\n
\ref IgnoreQueue_Set - Установка игнорирования очереди.\n
\ref IgnoreQueue_Reset - Сброс игнорирования очереди.\n
\ref Null - Действие-пустышка. Ничего не выполняет и сразу завершается.\n
\ref Call - Вызывает один раз передаваемую в единственном параметре функцию и завершается.
\n
\n

\section Graphical_and_moving_actions Действия, свазянные с графическим изменением картинки (alpha, scale, show, hide...) и передвижением.

<b>Графические действия</b>\n\n
\ref Show - Показ картинки.\n
\ref Show_Endless - Бесконечный показ картинки.\n
\ref Hide - Скрытие картинки.\n
\ref Show_Permit - Разрешить прорисовывать объект функцией Show() .\n
\ref Show_Refuse - Запретить прорисовывать объект функцией Show() .\n
\n
<b>Прозрачность</b>\n
\ref Alpha_Set - Установка уровня прозрачности.\n
\ref Alpha_Get - Получение текущего уровня прозрачности.\n
\ref Alpha_Change - Плавное изменение прозрачности от одного значения до другого за указанное время.\n
\n
<b>Масштаб</b>\n
\ref Scale_Set - Установка масштаба картинки.\n
\ref Scale_X_Set - Установка масштаба картинки.\n
\ref Scale_Y_Set - Установка масштаба картинки.\n
\ref Scale_X_Get - Получение масштаба картинки.\n
\ref Scale_Y_Get - Получение масштаба картинки.\n
\n
<b>Положение</b>\n
\ref Coord_X_Set - Установка координаты X.\n
\ref Coord_Y_Set - Установка координаты Y.\n
\ref Coord_X_Get - Получение координаты X.\n
\ref Coord_Y_Get - Получение координаты Y.\n
\n
<b>Угол вращения по оси Z</b>\n
\ref Angle_Set - Установка угла вращения по оси Z.\n
\ref Angle_Get - Получение угла вращения по оси Z.\n
\n
\n

\section Math Математика
<b>Арифметика</b>\n
\ref Sine - Получение синуса угла.\n
\ref Cosine - Получение синуса угла.\n
\ref Sum - Сложение двух величин.\n
\ref Difference - Разность двух величин.\n
\ref Product - Произведение двух величин.\n
\ref Quotient - Частное двух величин.\n
\ref Power - Возведение в степень.\n
\ref Negation - Отрицание числа.\n
\ref Magnitude - Модуль числа.\n
\n
<b>Прочее</b>\n
\ref Value_Change - Изменение величины с указанными скоростью и ускорением.\n
\ref Direction - Направление изменения величины.\n
\ref RandomValue - Получение случайного значения.\n
\n
<b>Кривая Безье</b>\n
\ref Bezier_Move - Перемещение по кривой Безье.\n
\ref Bezier_X - Получение координаты X на кривой Безье.\n
\ref Bezier_Y - Получение координаты Y на кривой Безье.\n
\ref Bezier_Direction - Получение направления кривой Безье в указанной её точке.\n
\n
\n

\section Actions_To_Dias Действия, свазянные с реализацией графики DIAS и звуков.

<b>Анимация</b>\n
\ref Animation_NextFrame - Переход к следующему кадру анимации.\n
\ref Animation_Draw - Отрисовка текущего кадра анимации.\n
\ref Animation_Start - Запуск анимации, начиная с текущего установленного кадра.\n
\ref Animation_SetCurrentFrame - Установка конкретного кадра анимации.\n
\n
<b>Звук</b>\n
\ref Sound_Play - Проигрывание звука в указанном канале.\n
\ref Sound_Continuous - Постоянное возобновление проигрывания звука.\n
\ref Sound_Fade - Запуск стандартной функции плавного изменения громкости звука.\n
\n
<b>Текстовая метка</b>\n
\ref Number_Set - Установка числа.\n
\ref Number_Get - Получение числа.\n
\ref Number_Flow - Перетекание числа.\n
\ref String_Set - Установка строки, отображаемой в TArtText.\n
\n
<b>Слой отображения объекта</b>\n
\ref Layer_Append - Добавление нового слоя.\n
\ref Layer_Switch - Переключение слоя отображения объекта.\n
\ref Layer_Clear - Удаление всех слоёв.\n
\ref Layer_SwitchUp - Переключение на следующий слой в списке слоёв.\n
\ref Layer_SwitchDown - Переключение на предыдущий слой в списке слоёв.\n
\ref Layer_First - Переключение на первый слой в списке слоёв.\n
\ref Layer_Last - Переключение на последний слой в списке слоёв.\n
\n
<b>Отражение картинки</b>\n
\ref Orientation_Set - Установка текущего отражения картинки.\n
\ref Orientation_Get - Получение текущего отражения картинки.\n
\ref Orientation_Flip_Horizontal - Инвертирование текущего отражения картинки по горизонтали.\n
\ref Orientation_Flip_Vertical - Инвертирование текущего отражения картинки по вертикали.\n
\n
<b>Прочее</b>\n
\ref Line_ScissorsSet - Установки ножниц для линий.\n
\n
\n


*/








