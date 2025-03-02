///@cond
package blisc.utils
{
	import blisc.instances.BliscComplex;
	import blisc.instances.BliscComplexWithinCompound;
	import blisc.instances.BliscCompound;
	import com.junkbyte.console.Cc;
	
	///@endcond
	
	
	/** Performs proper successive calls to specified complex or whole compound to animate it in a specified fashion.
	Utility class which just helps to implement routine animations - no special abstractions.*/
	public class Animator 
	{
		/** Used if BliscComplex was passed to constructor.*/
		private var _animating : BliscComplex = null;
		
		/** Used if BliscCompound was passed to constructor.*/
		private var _complexes : Vector.< Animator > = null;
		
		private var _played : Number = 0;
		
		private var _gap : Function = null;
		private var _gapping : Number = 0;
		private var _gappingWay : int;
		
		/** Totally hide object when it's gapping.*/
		public static const GAPPING_INVISIBLE : int = 1;
		/** Freeze object on first frame when it's gapping.*/
		public static const GAPPING_FIRST : int = 2;
		/** Freeze object on last frame when it's gapping.*/
		public static const GAPPING_LAST : int = 3;
		
		private var _play : int;
		
		/** Play animation once and stop. Gapping cannot be used with it.*/
		public static const PLAY_SINGLE : int = 1;
		/** Infinitely loop animation.*/
		public static const PLAY_LOOP : int = 2;
		
		
		/**
		\param something BliscComplex or BliscCompound.
		\param play Really dunno what will happen if play and gap will be mismatched :)
		*/
		public function Animator( something : *, gap : Function = null, gappingWay : int = GAPPING_FIRST, play : int = PLAY_LOOP )
		{
			_gap = gap;
			_gappingWay = gappingWay;
			
			_play = play;
			
			
			if ( something is BliscComplex )
			{
				_animating = something as BliscComplex;
			}
			else if ( something is BliscCompound )
			{
				var compound : BliscCompound = something as BliscCompound;
				
				if ( compound._complexes.length < 1 )
				{
					Cc.error( "E: Animator.Animator(): no children." );
				}
				//it's weird, yes, but it's 99% cases:
				else if ( compound._complexes.length == 1 )
				{
					_animating = compound._complexes[ 0 ]._complex;
				}
				else
				{
					_complexes = new Vector.< Animator >;
					for each ( var bcwc : BliscComplexWithinCompound in compound._complexes )
					{
						_complexes.push( new Animator( bcwc._complex, gap, gappingWay ) );
					}
				}
			}
			else
			{
				Cc.error( "E: Animator.Animator(): weird param passed." );
			}
			
			Gap();
		}
		
		private function Gap() : void
		{
			if ( _gap != null && _animating != null )
			{
				_gapping = _gap();
				if ( _gapping > 0 )
				{
					if ( _gappingWay == GAPPING_INVISIBLE )
					{
						Freeze();
					}
					else if ( _gappingWay == GAPPING_FIRST )
					{
						_animating._bdo.Replicate( _animating._template._view.first );
					}
					else
					{
						_animating._bdo.Replicate( _animating._template._view.last );
					}
				}
			}
		}
		
		/** Make animation disappear and ignore successive calls to Update() until Unfreeze() will be called.*/
		public function Freeze() : void
		{
			if ( _animating != null )
			{
				_animating._bdo.SetVisibility( false );
			}
			else if ( _complexes != null )
			{
				for each ( var child : Animator in _complexes )
				{
					child.Freeze();
				}
			}
		}
		
		/** Revert call to Freeze().*/
		public function Unfreeze() : void
		{
			if ( _animating != null )
			{
				_animating._bdo.SetVisibility( true );
			}
			else if ( _complexes != null )
			{
				for each ( var child : Animator in _complexes )
				{
					child.Unfreeze();
				}
			}
		}
		
		public function Update( seconds : Number ) : void
		{
			if ( _gapping > 0 )
			{
				_gapping -= seconds;
				if ( _gapping <= 0 )
				{
					if ( _gappingWay == GAPPING_INVISIBLE )
					{
						Unfreeze();
					}
				}
				else
				{
					return;
				}
			}
			
			if ( _animating != null )
			{
				if ( _animating._bdo.GetVisibility() )
				{
					_played += seconds;
					_animating._bdo.Replicate( _animating._template._view.Resolve( _played, _play == PLAY_LOOP ) );
					
					if ( _played >= _animating._template._view.period && _gap != null )
					{
						_played = 0;
						Gap();
					}
				}
			}
			else if ( _complexes != null )
			{
				for each ( var child : Animator in _complexes )
				{
					child.Update( seconds );
				}
			}
		}
		
		public function Destroy() : void
		{
			_animating = null;
			
			if ( _complexes != null )
			{
				for each ( var child : Animator in _complexes )
				{
					child.Destroy();
				}
				_complexes.length = 0;
				
				_complexes = null;
			}
			
			_gap = null;
		}
		
	}

}



