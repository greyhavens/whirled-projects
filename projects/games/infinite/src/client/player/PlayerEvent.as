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
	}
}
