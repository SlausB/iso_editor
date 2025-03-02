/// @cond
package
{
	import com.junkbyte.console.Cc;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
/// @endcond
	
	public class SensitiveHolder extends Sprite
	{
		/** Последние координаты мыши для скроллинга экрана.*/
		private var lastMouseCoordinates:Point = new Point;
		
		/** Ширина (и высота) области (границы) реагирования движения мыши как скроллинг экрана.*/
		private var SENSITIVE_X_BORDER:Number;
		private var SENSITIVE_Y_BORDER:Number;
		/** Скорость скроллинга если указатель мыши находится на грани реагируемой области ближе к центру экрана.*/
		private var PIXELS_PER_SECONDS_MIN:Number;
		/** Скорость скроллинга если указатель мыши находится у края игровокго экрана.*/
		private var PIXELS_PER_SECONDS_MAX:Number;
		
		public var container:Rectangle = new Rectangle(0, 0, 1024, 768);
		
		private var off:Boolean = false;
		
		private var moveHandler:Function = null;
		
		private var previousPos:Point = new Point;
		
		public function TurnOn(): void
		{
			off = false;
		}
		public function TurnOff(): void
		{
			off = true;
		}
		public function Drop(): void
		{
			this.x = 0;
			this.y = 0;
		}
		
		
		/** Размеры самого "чувствительного" спрайта.*/
		//private static const HOLDER_DIMENSIONS:Point = new Point(1024, 768);
		private var holderDimensions:Point = new Point(1024, 768);
		
		public function SensitiveHolder(sensitiveXBorder:Number, sensitiveYBorder:Number, pixelsPerSecondMin:Number, pixelsPerSecondMax:Number, moveHandler:Function = null)
		{
			this.SENSITIVE_X_BORDER = sensitiveXBorder;
			this.SENSITIVE_Y_BORDER = sensitiveYBorder;
			this.PIXELS_PER_SECONDS_MIN = pixelsPerSecondMin;
			this.PIXELS_PER_SECONDS_MAX = pixelsPerSecondMax;
			this.moveHandler = moveHandler;
		}
		
		public function OnMouseMove(mouseX:Number, mouseY:Number): void
		{
			lastMouseCoordinates.x = mouseX;
			lastMouseCoordinates.y = mouseY;
		}
		
		public function Update(seconds:Number): void
		{
			if (off)
			{
				return;
			}
			
			//скроллинг влево:
			if (lastMouseCoordinates.x <= SENSITIVE_X_BORDER)
			{
				//сдвиг за секунду:
				const speedLeft:Number = PIXELS_PER_SECONDS_MIN + (PIXELS_PER_SECONDS_MAX - PIXELS_PER_SECONDS_MIN) * ((SENSITIVE_X_BORDER - lastMouseCoordinates.x) / SENSITIVE_X_BORDER);
				const dispLeft:Number = speedLeft * seconds;
				this.x += dispLeft;
			}
			//скроллинг вправо:
			else
			{
				//сдвиг мыши за границу области скроллинга:
				const RIGHT_SHIFT:Number = lastMouseCoordinates.x - (stage.stageWidth - SENSITIVE_X_BORDER);
				
				if (RIGHT_SHIFT > 0)
				{
					//сдвиг за секунду:
					const speedRight:Number = PIXELS_PER_SECONDS_MIN + (PIXELS_PER_SECONDS_MAX - PIXELS_PER_SECONDS_MIN) * (RIGHT_SHIFT / SENSITIVE_X_BORDER);
					const dispRight:Number = speedRight * seconds;
					this.x -= dispRight;
				}
			}
			
			//скроллинг вверх:
			if (lastMouseCoordinates.y <= SENSITIVE_Y_BORDER)
			{
				//сдвиг за секунду:
				const speedUp:Number = PIXELS_PER_SECONDS_MIN + (PIXELS_PER_SECONDS_MAX - PIXELS_PER_SECONDS_MIN) * ((SENSITIVE_Y_BORDER - lastMouseCoordinates.y) / SENSITIVE_X_BORDER);
				const dispUp:Number = speedUp * seconds;
				this.y += dispUp;
			}
			//скроллинг вниз:
			else
			{
				//сдвиг мыши за границу области скроллинга:
				const DOWN_SHIFT:Number = lastMouseCoordinates.y - (stage.stageHeight - SENSITIVE_Y_BORDER);
				
				if (DOWN_SHIFT > 0)
				{
					//сдвиг за секунду:
					const speedDown:Number = PIXELS_PER_SECONDS_MIN + (PIXELS_PER_SECONDS_MAX - PIXELS_PER_SECONDS_MIN) * (DOWN_SHIFT / SENSITIVE_Y_BORDER);
					const dispDown:Number = speedDown * seconds;
					this.y -= dispDown;
				}
			}
			
			Draw();
		}
		
		public function Draw(): void
		{
			//если спрайт полностью помещается внутри пространства, в котором он должен "плавать", то просто размещаем его посередине этого пространства:
			
			//по оси X:
			//Cc.info("stage.stageWidth = " + stage.stageWidth + ", container.width = " + container.width + ", holderDimensions.x = " + holderDimensions.x);
			if (stage.stageWidth >= holderDimensions.x)
			{
				this.x = stage.stageWidth / 2.0 - holderDimensions.x / 2.0;
				//Cc.info("this.x = " + this.x);
			}
			else
			{
				if (this.x > 0)
				{
					this.x = 0;
				}
				else if (this.x + container.width < stage.stageWidth)
				{
					this.x = -container.width + stage.stageWidth;
				}
			}
			
			//по оси Y:
			//Cc.info("stage.stageHeight = " + stage.stageHeight + ", container.height = " + container.height + ", holderDimensions.y = " + holderDimensions.y);
			if (stage.stageHeight >= holderDimensions.y)
			{
				this.y = stage.stageHeight / 2.0 - holderDimensions.y / 2.0;
				//Cc.info("this.y = " + this.y);
			}
			else
			{
				if (this.y > 0)
				{
					this.y = 0;
				}
				else if (this.y + container.height < stage.stageHeight)
				{
					this.y = -container.height + stage.stageHeight;
				}
			}
			
			if (previousPos.x != this.x || previousPos.y != this.y && moveHandler != null)
			{
				moveHandler(this.x, this.y);
			}
			
			previousPos.x = this.x;
			previousPos.y = this.y;
		}
		
		public function SetHolderDimensions(x:Number, y:Number): void
		{
			this.holderDimensions = new Point(x, y);
		}
	}
}


