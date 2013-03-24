///@cond
package list_items
{
	import com.junkbyte.console.Cc;
	import mx.accessibility.AccConst;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	
	///@endcond
	
	/** Just some data holder for some list/table.*/
	public class ListItem extends Object
	{
		/** Which must form this object's view.*/
		protected var _data:Object;
		
		public function ListItem( data:Object )
		{
			_data = data;
		}
		
		public function get data(): Object
		{
			return _data;
		}
		public function set data( value:Object ): void
		{
			_data = value;
		}
		
		
		public static function UpdateListItem( data:Object, dp:IList, complain:Boolean = true, context:String = "" ): void
		{
			for ( var i:int = 0; i < dp.length; ++i )
			{
				var listItem:ListItem = dp.getItemAt( i ) as ListItem;
				if ( listItem == null )
				{
					continue;
				}
				
				if ( listItem.data == data )
				{
					dp.itemUpdated( listItem );
					return;
				}
			}
			
			Cc.error( "E: " + context + ": ListItem.UpdateListItem(): ListItem wasn't found." );
		}
		
	}

}

