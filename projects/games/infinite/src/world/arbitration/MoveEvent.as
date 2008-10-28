package world.arbitration
{
	import flash.events.Event;
	
	import paths.Path;
	
	import world.Player;

	public class MoveEvent extends Event
	{
		public static const PATH_START:String = "move_start"; 
    
        public var player:Player;

		public var path:Path;
		
		public function MoveEvent(type:String, player:Player, path:Path)
		{
			super(type);
			this.player = player;
			this.path = path;
		}
	}
}