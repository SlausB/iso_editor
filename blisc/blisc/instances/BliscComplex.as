///@cond
package blisc.instances 
{
	import blisc.core.BliscDisplayObject;
	import blisc.pathfinding.Restriction;
	import blisc.templates.BliscComplexTemplate;
	import flash.geom.Point;
	import view.Viewable;
	
	///@endcond
	
	public class BliscComplex
	{
		/** What specified this object.*/
		public var _template : BliscComplexTemplate;
		
		/** How this object is represented within isometry.*/
		public var _bdo : BliscDisplayObject;
		
		
		public function BliscComplex( template : BliscComplexTemplate, bdo : BliscDisplayObject )
		{
			_template = template;
			_bdo = bdo;
			_bdo.complex = this;
		}
		
		public function Destroy(): void
		{
			_bdo.Destroy();
			_bdo = null;
			
			_template = null;
		}
		
	}

}

