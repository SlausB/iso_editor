/// @cond
package iso
{
	import com.adobe.serialization.json.JSON;
	import com.junkbyte.console.Cc;
	import iso.orient.Combination;
	import iso.orient.Orientation;
	import utils.Utils;
	
	/// @endcond
	
	/** Тайл абстрактной поверхности - может быть, условно говоря, белой поверхностью, что по-умолчанию (например землёй), противоположной ей поверхностью - чёрной (например водой) или нейтральной поверхностью, рядом с которой есть хотя бы один тайл белой поверхности и хотя бы один чёрной (например берегом).
	*/
	public class AbstractMorph
	{
		/** Для возможности отмены выбора изменения тайла - этот вариант не может оказываться на сервере.*/
		public static const TYPE_UNDEFINED : int = 1;
		/** Тайл одного типа поверхности (считается по-умолчанию).*/
		public static const TYPE_WHITE : int = 2;
		/** Тайл типа поверхности, противоположного типу "по-умолчанию".*/
		public static const TYPE_BLACK : int = 3;
		/** Тайл нейтральной поверхности (где-то рядом находятся одновременно И тайл первого типа И тайл другого).*/
		public static const TYPE_NEUTRAL : int = 4;
		
		
		/** Форма именно текущего тайла.*/
		public var _combination : Combination;
		
		protected var _opaqueData : *;
		protected var _getNeighbour : Function;
		protected var _onChange : Function;
		protected var _resolver : Function;
		
		public var _type : int;
		
		
		/** Конструктор.
		\param combination Форма именно текущего тайла.
		\param opaqueData Именно это и передаётся во все callback'и.
		\param getNeighbour function( orientation : int, opaqueData : * ) : Morph - способ получения соседа когда нужно его обновить; должна возвращать null если соседа нет.
		\param onChange function( combination : Combination, directions : Vector.< int >, opaqueData : * ) : void, где directions - массив направлений углов чёрной поверхности нового тайла, получившегося в результате морфинга. Вызывается по результатам морфинга - нужно, например, изменить картинку тайла согласно новым углам берега.
		\param resolver function( directions : Vector.< int > ) : Combination - поиск тайла по направлениям к соседним тайлам чёрной поверхности.
		*/
		public function AbstractMorph(
            combination : Combination,
            opaqueData : *,
            getNeighbour : Function,
            onChange : Function,
            resolver : Function,
            type : int
        ) {
			_combination = combination;
			
			_opaqueData = opaqueData;
			_getNeighbour = getNeighbour;
			_onChange = onChange;
			_resolver = resolver;
			
			_type = type;
		}
		
		/** Тайл, полностью заполненный углами чёрной поверхности.*/
		public static function GetFullBlack() : Vector.< int >
		{
			return new < int >[ Orientation.N, Orientation.E, Orientation.S, Orientation.W ];
		}
		
		public function ApplyDirections( directions : Vector.< int >, toWhat : int ) : void
		{
			ResolveCombination( directions, toWhat );
			
			CallOnChange( directions );
		}
		
		/** Возвращает тип текущей поверхности - одно из: TYPE_WHITE, TYPE_BLACK, TYPE_NEUTRAL.*/
		public function Type() : int
		{
			if ( _combination._directions.length <= 0 )
			{
				return TYPE_WHITE;
			}
			else if ( _combination._directions.length >= 4 )
			{
				return TYPE_BLACK;
			}
			
			return TYPE_NEUTRAL;
		}
		
		public function CallOnChange( directions : Vector.< int > ) : void
		{
			_onChange( _combination, directions, _opaqueData );
		}
		
		public function ResolveCombination( directions : Vector.< int >, toWhat : int ) : void
		{
			_combination = _resolver( directions, toWhat );
			if ( _combination == null )
			{
				Cc.error( "E: AbstractMorph.ResolveCombination(): resolved combination for \"" + Utils.Print( directions ) + "\" : " + toWhat.toString() + " is null." );
			}
		}
		
	}

}

