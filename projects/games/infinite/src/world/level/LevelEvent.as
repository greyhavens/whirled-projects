package world.level
{
	import flash.events.Event;
	
	import world.Player;

	public class LevelEvent extends Event
	{
		public function LevelEvent(type:String, level:Level, player:Player)
		{
			super(type);
			_level = level;
			_player = player;
		}
		
		protected var _level:Level;
		protected var _player:Player;
		
		public static const LEVEL_ENTERED:String = "level_entered";
	}
}