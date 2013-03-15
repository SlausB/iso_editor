///@cond
package ie 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import project_data.ComplexTemplate;
	import project_data.ComplexWithinCompound;
	import project_data.SingleResource;
	import utils.Utils;
	
	///@endcond
	
	/** Used within EditingTemplateWindow.*/
	public class DraggingComplex extends Sprite
	{
		/** Isn't NULL when used for Compound.*/
		public var _withinCompound:ComplexWithinCompound;
		
		public var _complex:ComplexTemplate;
		
		public var _aimingResource:SingleResource = null;
		
		public var _view:DisplayObject = null;
		
		
		public function DraggingComplex( complex:ComplexTemplate, project:Project, withinCompound:ComplexWithinCompound = null )
		{
			_complex = complex;
			_withinCompound = withinCompound;
			
			if ( complex._singleResource != null )
			{
				Aim( complex._singleResource, project );
			}
			
			if ( withinCompound != null )
			{
				var planar:Point = Utils.FromIso( withinCompound._tileDispX * project.side, withinCompound._tileDispY * project.side, new Point );
				x = planar.x;
				y = planar.y;
			}
		}
		
		public function Aim( singleResource:SingleResource, project:Project ): void
		{
			_aimingResource = singleResource;
			
			Utils.RemoveAllChildren( this );
			
			_view = singleResource.Display( project );
			if ( _withinCompound != null )
			{
				_view.x = _complex._disp.x;
				_view.y = _complex._disp.y;
			}
			addChild( _view );
		}
		
		public function GetSingleResource(): SingleResource
		{
			return _withinCompound == null ? _complex._singleResource : _withinCompound._complex._singleResource;
		}
		
		public function Destroy(): void
		{
			Utils.RemoveAllChildren( this );
			
			_withinCompound = null;
			_complex = null;
			
			_aimingResource = null;
			
			_view = null;
		}
		
	}

}

