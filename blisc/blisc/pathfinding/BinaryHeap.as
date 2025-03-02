///@cond
package blisc.pathfinding
{
	
	///@endcond
	
	
	/** Min binary heap specifically for our pathfinding task.*/
	public class BinaryHeap
	{
		private var _content : Vector.< AStarNode > = new Vector.< AStarNode >;
		
		
		public function reset() : void
		{
			_content.length = 0;
			_content = new Vector.< AStarNode >;
		}
		
		
		public function push( element : AStarNode ) : void
		{
			//add the new element to the end of the array:
			_content.push( element );
			
			const index : int = _content.length - 1;
			
			element._index = index;
			
			//allow it to bubble up:
			bubbleUp( index );
		}
		
		public function pop() : AStarNode
		{
			//store the first element so we can return it later:
			var result : AStarNode = _content[ 0 ];
			
			//get the element at the end of the array:
			var end : AStarNode = _content.pop();
			
			//if there are any elements left, put the end element at the start, and let it sink down:
			if ( _content.length > 0 )
			{
				_content[ 0 ] = end;
				end._index = 0;
				sinkDown( 0 );
			}
			return result;
		}
		
		
		public function get size() : int
		{
			return _content.length;
		}
		
		
		public function rescoreElement( node : AStarNode, previousValue : Number ) : void
		{
			if ( node._f < previousValue )
			{
				bubbleUp( node._index );
			}
			else if ( node._f > previousValue )
			{
				sinkDown( node._index );
			}
		}
		
		private function Swap( parentIndex : int, childIndex : int ) : void
		{
			var child : AStarNode = _content[ childIndex ];
			var parent : AStarNode = _content[ parentIndex ];
			_content[ childIndex ] = parent;
			_content[ parentIndex ] = child;
			
			child._index = parentIndex;
			parent._index = childIndex;
		}
		
		private function bubbleUp( n : int ) : void
		{
			var element : AStarNode = _content[ n ];
			
			//when at 0, an element can not bubble any further:
			while ( element._index > 0 )
			{
				var	parent : AStarNode = _content[ Math.floor( ( element._index - 1 ) / 2 ) ];
				
				//swap the elements if the parent is greater:
				if ( element._f < parent._f )
				{
					Swap( parent._index, element._index );
				}
				//found a parent that is less, no need to bubble any further:
				else
				{
					break;
				}
			}
		}
		
		private function sinkDown( n : Number ) : void
		{
			const length : int = _content.length;
			var element : AStarNode = _content[ n ];
			const elemScore : Number = element._f;
			
			for ( ;; )
			{
				//compute the indices of the child elements:
				const child1N : int = element._index * 2 + 1;
				const child2N : int = child1N + 1;
				
				//this is used to store the new position of the element, if any:
				var swap : * = null;
				
				//if the first child exists (is inside the array):
				if ( child1N < length )
				{
					//look it up and compute its score:
					var child1 : AStarNode = _content[ child1N ];
					//if the score is less than our element's, we need to swap:
					if ( child1._f < elemScore )
					{
						swap = child1N;
					}
				}
				//do the same checks for the other child:
				if ( child2N < length )
				{
					var child2 : AStarNode = _content[ child2N ];
					if ( child2._f < ( swap == null ? elemScore : child1._f ) )
					{
						swap = child2N;
					}
				}
				
				//if the element needs to be moved, swap it, and continue:
				if ( swap != null )
				{
					Swap( element._index, swap as int );
				}
				//otherwise, we are done:
				else
				{
					break;
				}
			}
		}
	}
}

