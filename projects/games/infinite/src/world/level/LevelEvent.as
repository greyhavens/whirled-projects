package world.level
{
	import flash.events.Event;
	
	import world.Player;

	public class LevelEvent extends Event
	{
        public var level:Level;
        public var player:Player;
		
		public function LevelEvent(type:String, level:Level, player:Player)
		{
			super(type);
			this.level = level;
		    this.player = player;
		}        
		
		override public function clone() :Event
		{
			return new LevelEvent(type, level, player);
		}
		
		public static const LEVEL_ENTERED:String = "level_entered";
	}
}