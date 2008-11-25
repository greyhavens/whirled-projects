package client.player
{
	import flash.events.Event;

	public class PlayerEvent extends Event
	{
		public var player:Player;		
		
		public function PlayerEvent(type:String, player:Player)
		{
			this.player = player;
			super(type);			
		}
		
		public static const CHANGED_LEVEL:String = "changed_level";		
        public static const PATH_STARTED:String = "path_started";     
        public static const PATH_COMPLETED:String = "path_completed";
        public static const RADAR_UPDATE:String = "radar_update";     
	}
}
