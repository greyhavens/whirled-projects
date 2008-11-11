package client
{
	import client.player.Player;
	
	import flash.utils.Dictionary;
	
	
	public class PlayerRegister
	{
		public function PlayerRegister()
		{
		}

		public function find (id:int) :Player
		{
			return _dictionary[id] as Player;
		}

		public function register (player:Player) :void
		{
		    Log.debug(this + " registering " + player);
			_dictionary[player.id] = player;
			_list.push(player);
		}

		public function get list () :Array
		{
			return _list;
		}

		public function toString () :String
		{
			return "client player register";
		}

        protected var _list:Array = new Array();
        protected var _dictionary:Dictionary = new Dictionary();
	}
}