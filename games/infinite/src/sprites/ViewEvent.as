package sprites
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class ViewEvent extends Event
	{
		public var view:DisplayObject;
		
		public function ViewEvent(type:String, view:DisplayObject)
		{			
			this.view = view;			
			super(type);
		}
		
		public static const MOVED:String = "moved";		
	}
}