package iso 
{
	/** Отложенное изменение объектов в результате терраморфинга.*/
	public class Change
	{
		public var _morphDirs : MorphDirs;
		public var _directions : Vector.< int >;
		public var _toWhat : int;
		
		public function Change( morphDirs : MorphDirs, directions : Vector.< int >, toWhat : int )
		{
			_morphDirs = morphDirs;
			_directions = directions;
			_toWhat = toWhat;
		}
	}

}

