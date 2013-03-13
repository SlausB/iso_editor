///@cond
package  
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import mx.managers.ToolTipManager;
	import project_data.SingleResource;
	
	///@endcond
	
	
	public class SingleResourcePreview 
	{
		public var _singleResource:SingleResource;
		public var _view:DisplayObject;
		public var _project:Project;
		
		public function SingleResourcePreview( singleResource:SingleResource, view:DisplayObject, project:Project )
		{
			_singleResource = singleResource;
			_view = view;
			_project = project;
			
			_view.addEventListener( MouseEvent.MOUSE_OVER, OnOver );
			_view.addEventListener( MouseEvent.MOUSE_OUT, OnOut );
			_view.addEventListener( MouseEvent.MOUSE_DOWN, OnDown );
		}
		
		public function Destroy(): void
		{
			_view.removeEventListener( MouseEvent.MOUSE_OVER, OnOver );
			_view.removeEventListener( MouseEvent.MOUSE_OUT, OnOut );
			_view.removeEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			
			_singleResource = null;
			_view = null;
			_project = null;
		}
		
		private function OnOver( ... args ): void
		{
			_view.filters = [ new GlowFilter( 0x44C97C, 1, 6, 6, 8 ) ];
			
			ResourcesPreview.HideTip();
			ResourcesPreview._resourceTip = ToolTipManager.createToolTip( '"' + _singleResource._name + '". Drag and drop it to template editing window.', _view.stage.mouseX, _view.stage.mouseY );
		}
		
		private function OnOut( ... args ): void
		{
			_view.filters = [];
			
			ResourcesPreview.HideTip();
		}
		
		private function OnDown( event:MouseEvent ): void
		{
			Main.StartDrag( event, _singleResource, Global.DRAG_FORMAT_SINGLE_RESOURCE, _singleResource.FindClass( _project ) );
		}
	}

}


