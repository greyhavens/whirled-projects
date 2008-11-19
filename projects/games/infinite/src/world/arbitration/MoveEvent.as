package world.arbitration
{
	import flash.events.Event;
	
	import paths.Path;
	
	public class MoveEvent extends Event
	{
		public static const PATH_START:String = "move_start";
		public static const FALL_START:String = "fall_start"; 
    
        public var player:MovablePlayer;

		public var path:Path;
		
		public function MoveEvent(type:String, player:MovablePlayer, path:Path)
		{
			super(type);
			this.player = player;
			this.path = path;
		}
		
		override public function clone () :Event
		{
			return new MoveEvent(type, player, path);
		}
	}
}