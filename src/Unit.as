///@cond
package
{
	import blisc.BliscCompound;
	import blisc.BliscIsometric;
	import blisc.BliscUnit;
	import blisc.pathfinding.AStarNode;
	import blisc.templates.BliscUnitTemplate;
	import blisc.unit_actions.MoveDirectly;
	import blisc.unit_actions.MoveTiled;
	import blisc.unit_actions.UnitAction;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import project_data.Map;
	import project_data.ObjectInstance;
	import utils.Utils;
	
	///@endcond
	
	
	/** Random walking unit within isometry.*/
	public class Unit extends IsometryObject
	{
		public var _unitDesc:UnitDesc;
		
		private var _currentAction:UnitAction = null;
		
		private var _isoDest:Point = new Point;
		
		
		public function Unit( main:Main, unitDesc:UnitDesc )
		{
			super( null, main );
			
			_unitDesc = unitDesc;
		}
		
		public function Init( view : BliscIsometric ) : void
		{
			_view = view;
			
			MoveRandomly();
		}
		
		public function get unitDesc(): UnitDesc
		{
			return _unitDesc;
		}
		
		override public function Update( elapsedSeconds:Number ): void
		{
			if ( _currentAction == null )
			{
				return;
			}
			
			const left:Number = elapsedSeconds - _currentAction.Proceed( elapsedSeconds );
			//ended:
			if ( left > 0 )
			{
				if ( _currentAction is MoveDirectly )
				{
					MoveRandomly( _isoDest.x, _isoDest.y );
					_currentAction.Proceed( left );
				}
			}
		}
		
		private function get map(): Map
		{
			return _main._isometry.displaying;
		}
		
		private function MoveRandomly( startX:Number = 0, startY:Number = 0 ): void
		{
			if ( _currentAction != null )
			{
				_currentAction.Destroy();
			}
			
			Utils.ToIso( Utils.RandomInt( -map._right, map._right ), Utils.RandomInt( -map._down, map._down ), _isoDest );
			_currentAction = new MoveDirectly( _view as BliscUnit, parseFloat( _main._unitsSpeed.text ), startX, startY, _isoDest.x, _isoDest.y );
		}
		
		override public function Highlight( glowFilter:GlowFilter ): void
		{
			_view.bdo.Highlight( glowFilter );
		}
		
		override public function Unhighlight(): void
		{
			_view.bdo.Unhighlight();
		}
		
		public function MoveTo( isoX:Number, isoY:Number, tiled:Boolean = false ): void
		{
			if ( _currentAction != null )
			{
				_currentAction.Destroy();
				_currentAction = null;
			}
			
			_isoDest.setTo( isoX, isoY );
			
			var moveDirectly : Boolean = false;
			
			if ( tiled )
			{
				//units stay on tile's center:
				const startX : Number = _view.GetIsoX() - _view._blisc.tileSide / 2;
				const startY : Number = _view.GetIsoY() - _view._blisc.tileSide / 2;
				var start : AStarNode = _view._blisc._aStar.grid.GetTile( Math.round( startX / _view._blisc.tileSide ), Math.round( startY / _view._blisc.tileSide ) );
				var end : AStarNode = _view._blisc._aStar.grid.GetTile( Math.round( isoX / _view._blisc.tileSide ), Math.round( isoY / _view._blisc.tileSide ) );
				var path : Vector.< AStarNode > = _view._blisc._aStar.search( ( _view as BliscUnit )._template, start, end );
				if ( path == null )
				{
					trace( "path not found" );
					moveDirectly = true;
				}
				else
				{
					trace( "found path consisting from " + path.length.toString() + " tiles:" );
					for ( var i : int = 0; i < path.length; ++i )
					{
						trace( "	" + path[ i ].tileX.toString() + " | " + path[ i ].tileY.toString() );
					}
					
					_currentAction = new MoveTiled( _view as BliscUnit, path, parseFloat( _main._unitsSpeed.text ), _view.bdo.GetIsoX(), _view.bdo.GetIsoY(), isoX, isoY );
				}
			}
			else
			{
				moveDirectly = true;
			}
			
			if ( moveDirectly )
			{
				_currentAction = new MoveDirectly( _view as BliscUnit, parseFloat( _main._unitsSpeed.text ), _view.bdo.GetIsoX(), _view.bdo.GetIsoY(), isoX, isoY );
			}
		}
		
	}

}

