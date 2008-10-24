package client
{
	import flash.utils.Dictionary;
	
	
	public class PlayerRegister
	{
		public function PlayerRegister()
		{
		}
		
		public function find (id:int) :RemotePlayer
		{
			return _dictionary[id] as RemotePlayer;
		}
		
		public function register (player:RemotePlayer) :void
		{
			_dictionary[player.id] = player;
		}

        protected var _dictionary:Dictionary = new Dictionary();
	}
}