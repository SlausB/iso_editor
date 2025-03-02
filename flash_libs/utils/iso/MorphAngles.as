/// @cond
package iso
{
	import iso.orient.Combination;
	import iso.orient.Orientation;
	
	/// @endcond
	
	/** Тайл нейтральной поверхности условно поделён на 4 части (угла - север, восток, юг, запад), где каждый из углов может примыкать либо к белой, либо к чёрной поверхности. Если все четыре угла примыкают к белой поверхности, то этот нейтральный тайл сам становится этой белой поверхностью и наоборот для чёрной поверхности.
	*/
	public class MorphAngles extends AbstractMorph
	{
		public function Morph(
            combinations:Array,
            combination:Combination,
            opaqueData:*,
            getNeighbour:Function,
            onChange:Function
        ) {
			super(
                combinations,
                combination,
                opaqueData,
                getNeighbour,
                onChange
            );
		}
		
		/** Установить на указанных углах (N, E, S, W) текущего тайла землю.*/
		public function ChangeAnglesToWhite(angles:Array): void
		{
			//тайл земли и так НЕ содержит воды:
			if (Type() == TYPE_WHITE)
			{
				return;
			}
			
			//новые углы с чёрной поверхностью будут только те, которые были прежде, но которых нет в angles:
			var newAngles:Array = [];
			var previousAngles:Array = combination.directions.concat();
			
			for each(var angle:int in previousAngles)
			{
				//проверяем что старого угла чёрной поверхности нет в списке тех углов, которые планируется заменить на светлую:
				var within:Boolean = false;
				for each(var toWhiteAngle:int in angles)
				{
					if (angle == toWhiteAngle)
					{
						within = true;
						break;
					}
				}
				
				if (!within)
				{
					newAngles.push(angle);
				}
			}
			
			Utils.Unify(newAngles);
			
			ApplyDirections(newAngles);
		}
		
		/** Установить на указанных углах (N, E, S, W) текущего тайла воду.*/
		public function ChangeAnglesToBlack(angles:Array): void
		{
			//тайл воды итак полностью заполнен водой:
			if (Type() == TYPE_BLACK)
			{
				return;
			}
			
			var newAngles:Array = combination.directions.concat();
			
			for each(var angle:int in angles)
			{
				newAngles.push(angle);
			}
			
			Utils.Unify(newAngles);
			
			ApplyDirections(newAngles);
		}
		
		/** Осуществить изменение объекта в белую или чёрную поверхность.
		Соседние тайлы будут корректно обработаны.
		\param toWhat В какую поверхность менять: TYPE_WHITE или TYPE_BLACK.
		\param quarters Какие уголки тайла менять (N, E, S, W).
		*/
		public function DoMorph(toWhat:int, quarters:Array): void
		{
			//обновляем текущий тайл:
			switch(toWhat)
			{
				case TYPE_WHITE:
				ChangeAnglesToWhite(quarters);
				break;
				
				case TYPE_BLACK:
				ChangeAnglesToBlack(quarters);
				break;
				
				default:
				trace("E: MorphAngles.DoMorph(): toWhat = " + toWhat + " is undefined.");
				return;
			}
			
			
			//обновляем все соседние тайлы в результате изменения типа текущего тайла...
			
			/*текущая (обновление - усовершенствование старой) заключается в следующем: изменяться состояния тайла могут только его четвертинками (далее просто Ч), где изменение всего тайла - это частный случай изменения Ч-ок, в котором ВСЕ они изменяются. При изменении Ч-ки изменяться должны только по одной Ч-ке трёх соседних тайлов, пример: изменяется северная Ч - должны измениться Ч-ки в других тайлах следующим образом:
				- восточная Ч северо-западного тайла
				- южная Ч северного тайла
				- западная Ч северо-восточного тайла
			Таким же образом обрабатываются соседние тайлы остальных трёх Ч-ок (с соответствующим соотношением).
			*/
			
			//объединяем результат изменения всех Ч-ок в один морфинг, чтобы не делать его (который довольно-таки медленный в графической своей части) отдельно для каждой Ч-ки:
			var neighbours:Array = [[], [], [], [], [], [], [], []];
			
			function Add(direction:int, angle:int): void
			{
				neighbours[direction].push(angle);
			}
			
			//обрабатываем соседей каждой Ч-ки:
			for each(var quarter:int in quarters)
			{
				//увы, алгоритма для получения соседних тайлов для каждой Ч-ки я не нашёл, поэтому получаем их жёстко (к тому же их всего-то 4):
				switch(quarter)
				{
					case Orientation.N:
					Add(Orientation.NW, Orientation.E);
					Add(Orientation.N, Orientation.S);
					Add(Orientation.NE, Orientation.W);
					break;
					
					case Orientation.E:
					Add(Orientation.NE, Orientation.S);
					Add(Orientation.E, Orientation.W);
					Add(Orientation.SE, Orientation.N);
					break;
					
					case Orientation.S:
					Add(Orientation.SE, Orientation.W);
					Add(Orientation.S, Orientation.N);
					Add(Orientation.SW, Orientation.E);
					break;
					
					case Orientation.W:
					Add(Orientation.SW, Orientation.N);
					Add(Orientation.W, Orientation.E);
					Add(Orientation.NW, Orientation.S);
					break;
					
					default:
					trace("E: Morph.DoMorph(): quarter = " + quarter + " is undefined.");
					break;
				}
			}
			
			//обновляем только те соседние тайлы, Ч-ки которых были изменены в результате изменения Ч-ок(-ки) текущего тайла:
			for (var neighbourIndex:int = 0; neighbourIndex < neighbours.length; neighbourIndex++)
			{
				var neighbour:Array = neighbours[neighbourIndex];
				if (neighbour.length <= 0)
				{
					continue;
				}
				
				var updatingNeighbour:Morph = getNeighbour(neighbourIndex, opaqueData);
				if (updatingNeighbour != null)
				{
					switch(toWhat)
					{
						case TYPE_WHITE:
						updatingNeighbour.ChangeAnglesToWhite(neighbour);
						break;
						
						case TYPE_BLACK:
						updatingNeighbour.ChangeAnglesToBlack(neighbour);
						break;
						
						default:
						trace("E: Morph.DoMorph(): toWhat = \"" + toWhat + "\" is undefined.");
						break;
					}
				}
			}
		}
	}

}

