///@cond
package blisc.unit_actions
{
	import blisc.instances.BliscUnit;
	import blisc.templates.BliscUnitTemplate;
	import com.junkbyte.console.Cc;
	import iso.orient.Orientation;
	
	///@endcond
	
	
	/** Something like Behaviour Tree element.*/
	public class UnitAction
	{
		/** Unit to operate on.*/
		protected var _unit : BliscUnit;
		/** Where to get animation from and surface (walkability) properties.*/
		protected var _template : BliscUnitTemplate;
		
		/** Must be set to true if action cannot be executed (proceeded) furthermore.*/
		public var _failed : Boolean = false;
		
		
		/** .
		\param unit Unit to operate on.
		\param template Where to get animation from and surface (walkability) properties.
		*/
		public function UnitAction( unit : BliscUnit, template : BliscUnitTemplate )
		{
			_unit = unit;
			_template = template;
		}
		
		/** Passed time can be zero when called at action start.
		\return Amount of seconds action consumed. If less then passed seconds then action was ended.
		*/
		public function Proceed( seconds : Number ) : Number
		{
			return 0;
		}
		
		/** Can be called at any time - clean up yourself - you will never be used again.*/
		public function Destroy() : void
		{
			_unit = null;
		}
		
		/** Must return orientation unit's animation is currently facing.*/
		public function get orientation() : int
		{
			Cc.error( "E: UnitAction.get orientation(): pure virtual function call." );
			return Orientation.U;
		}
		
	}

}

