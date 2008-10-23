package world
{
	import flash.events.Event;

	public class PlayerEvent extends Event
	{
		public function PlayerEvent(type:String, player:Player)
		{
			_player = player;
			super(type);
		}
		
		public function get player () :Player
		{
			return _player;
		}
		
		protected var _player:Player;
		
		public static const MOVE_COMPLETED:String = "move_completed";
	}
}