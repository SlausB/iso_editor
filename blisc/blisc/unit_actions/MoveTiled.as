///@cond
package blisc.unit_actions
{
	import blisc.instances.BliscUnit;
	import blisc.pathfinding.AStarNode;
	import blisc.pathfinding.Path;
	import blisc.templates.BliscUnitTemplate;
	import flash.geom.Point;
	
	///@endcond
	
	
	/** Move through specified path tile-by-tile.*/
	public class MoveTiled extends UnitAction
	{
		private var _path : Path;
		
		/** From which to which point unit is moving right now within path.*/
		private var _currentStep : MoveDirectly;
		private var _played : Number = 0;
		
		/** To which tile we are currently moving - right on next tile after path start from current positiong.*/
		private var _currentIndex : int = 1;
		
		/** Just caching.*/
		private var _destIsoPos : Point = new Point;
		
		private var _isoDestX : Number;
		private var _isoDestY : Number;
		
		private var _speed : Number;
		
		
		public function MoveTiled(
			unit : BliscUnit,
			template : BliscUnitTemplate,
			path : Path,
			speed : Number,
			isoStartX : Number,
			isoStartY : Number,
			isoDestX : Number,
			isoDestY : Number
		)
		{
			super( unit, template );
			
			_path = path;
			_speed = speed;
			_isoDestX = isoDestX;
			_isoDestY = isoDestY;
			
			FillDest();
			
			//from current position to second tile within path:
			_currentStep = new MoveDirectly( unit, template, speed, isoStartX, isoStartY, _destIsoPos.x, _destIsoPos.y, true );
		}
		
		private function FillDest() : void
		{
			if ( _currentIndex >= _path._path.length
				||
				//as with first movement - move directly to specified point from penultimate tile instead of just to last:
				( _currentIndex == ( _path._path.length - 1 )
				//for incomplete paths unit should NOT hover through unpassable tiles which pathfinding couldn't pass:
				&& _path._complete == true ) )
			{
				_destIsoPos.x = _isoDestX;
				_destIsoPos.y = _isoDestY;
				return;
			}
			
			var tile : AStarNode = _path._path[ _currentIndex ];
			
			//+0.5 because unit must stay at tile's center instead of north:
			_destIsoPos.x = ( tile._tileX + 0.5 ) * _unit._blisc.tileSide;
			_destIsoPos.y = ( tile._tileY + 0.5 ) * _unit._blisc.tileSide;
		}
		
		override public function Proceed( seconds : Number ) : Number
		{
			var result : Number = seconds;
			
			_played += seconds;
			
			while ( seconds > 0 )
			{
				_currentStep._played = _played;
				seconds -= _currentStep.Proceed( seconds );
				if ( seconds > 0 )
				{
					++_currentIndex;
					
					if ( _currentIndex >= _path._path.length )
					{
						return result - seconds;
					}
					
					FillDest();
					
					_currentStep.Init( _unit, _speed, _unit.GetIsoX(), _unit.GetIsoY(), _destIsoPos.x, _destIsoPos.y, true );
				}
			}
			
			return result;
		}
		
		override public function Destroy() : void
		{
			_path.Destroy();
			_path = null;
			
			if ( _currentStep != null )
			{
				_currentStep.Destroy();
				_currentStep = null;
			}
			
			
			super.Destroy();
		}
		
		override public function get orientation() : int
		{
			return _currentStep.orientation;
		}
		
	}

}



