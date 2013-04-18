///@cond
package
{
	import blisc.instances.BliscIsometric;
	import blisc.instances.BliscUnit;
	import blisc.pathfinding.AStarNode;
	import blisc.templates.BliscUnitTemplate;
	import blisc.unit_actions.Idle;
	import blisc.unit_actions.MoveDirectly;
	import blisc.unit_actions.MoveTiled;
	import blisc.unit_actions.UnitAction;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import iso.orient.Orientation;
	import project_data.Map;
	import project_data.Resource;
	import project_data.UnitProperties;
	import utils.Utils;
	
	///@endcond
	
	
	/** Random walking unit within isometry.*/
	public class Unit extends IsometryObject
	{
		public var _unitDesc : UnitDesc;
		
		private var _currentAction : UnitAction = null;
		
		private var _isoDest : Point = new Point;
		
		
		public function Unit( main:Main, unitDesc:UnitDesc )
		{
			super( null, main );
			
			_unitDesc = unitDesc;
		}
		
		public function Init( view : BliscIsometric, tileX : Number, tileY : Number ) : void
		{
			_view = view;
			
			_view.SetTileXY( tileX, tileY );
			
			if ( _main._stroll.selected )
			{
				MoveRandomly();
			}
			else
			{
				Idle();
			}
		}
		
		public function get unitDesc() : UnitDesc
		{
			return _unitDesc;
		}
		
		override public function Update( elapsedSeconds : Number ) : void
		{
			if ( _currentAction != null )
			{
				const left : Number = elapsedSeconds - _currentAction.Proceed( elapsedSeconds );
				//ended:
				if ( left > 0 )
				{
					var destroy : Boolean = false;
					
					if ( _currentAction is MoveDirectly )
					{
						if ( _main._stroll.selected )
						{
							MoveRandomly();
							_currentAction.Proceed( left );
						}
						else
						{
							destroy = true;
						}
					}
					else if ( _currentAction is MoveTiled )
					{
						if ( _main._stroll.selected )
						{
							MoveRandomly();
							_currentAction.Proceed( left );
						}
						else
						{
							destroy = true;
						}
					}
					else if ( _currentAction is blisc.unit_actions.Idle )
					{
						if ( _main._stroll.selected )
						{
							MoveRandomly();
							_currentAction.Proceed( left );
						}
						else
						{
							Idle();
							_currentAction.Proceed( left );
						}
					}
					else
					{
						destroy = true;
					}
					
					if ( destroy )
					{
						_currentAction.Destroy();
						_currentAction = null;
					}
				}
			}
			
			if ( _currentAction == null )
			{
				Idle();
			}
		}
		
		private function Idle() : void
		{
			DropAction();
			
			var template : BliscUnitTemplate;
			for each ( var resource : Resource in _main._project._data._resources )
			{
				for each ( var unitDesc : UnitDesc in resource._units )
				{
					if ( unitDesc._template._name == _unitDesc._template._name && unitDesc._template._animation == "idle" )
					{
						template = unitDesc._template;
						break;
					}
				}
			}
			_currentAction = new blisc.unit_actions.Idle( ( _view as BliscUnit ), template, Orientation.S );
		}
		
		private function get map() : Map
		{
			return _main._isometry.displaying;
		}
		
		private function MoveRandomly() : void
		{
			DropAction();
			
			Utils.ToIso( Utils.RandomInt( -map._right, map._right ), Utils.RandomInt( -map._down, map._down ), _isoDest );
			MoveTo( _isoDest.x, _isoDest.y, _main._strictMove.selected );
		}
		
		private function DropAction() : void
		{
			if ( _currentAction != null )
			{
				_currentAction.Destroy();
				_currentAction = null;
			}
		}
		
		override public function Highlight( glowFilter : GlowFilter ) : void
		{
			_view.bdo.Highlight( glowFilter );
		}
		
		override public function Unhighlight(): void
		{
			_view.bdo.Unhighlight();
		}
		
		public function MoveTo( isoX : Number, isoY : Number, tiled : Boolean = false ) : void
		{
			DropAction();
			
			_isoDest.setTo( isoX, isoY );
			
			var moveDirectly : Boolean = false;
			
			if ( tiled )
			{
				//units stay on tile's center:
				const startX : Number = _view.GetIsoX() - _view._blisc.tileSide / 2;
				const startY : Number = _view.GetIsoY() - _view._blisc.tileSide / 2;
				var start : AStarNode = _view._blisc._aStar.grid.GetTile(
					Math.round( startX / _view._blisc.tileSide ),
					Math.round( startY / _view._blisc.tileSide ) );
				var end : AStarNode = _view._blisc._aStar.grid.GetTile(
					Math.round( isoX / _view._blisc.tileSide ),
					Math.round( isoY / _view._blisc.tileSide ) );
				var path : Vector.< AStarNode > = _view._blisc._aStar.search( ( _view as BliscUnit )._template, start, end, _main._project._data._slippingValue );
				if ( path == null )
				{
					//keep unit standing or doing what he was doing:
					//moveDirectly = true;
					Idle();
				}
				else
				{
					_currentAction = new MoveTiled(
						_view as BliscUnit,
						path,
						parseFloat( _main._unitsSpeed.text ),
						_view.bdo.GetIsoX(),
						_view.bdo.GetIsoY(),
						isoX,
						isoY );
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

