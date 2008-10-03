package paths
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class PathEvent extends Event
	{
		public static const PATH_START:String = "path_start"; 

		public var path:Path
		
		public function PathEvent(type:String, path:Path)
		{
			super(type);
			this.path = path;
		}
	}
}