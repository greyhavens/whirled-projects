package client
{
	import client.player.Player;
	
	import flash.utils.Dictionary;
	
	
	public class ClientPlayers implements Owners
	{
		public function ClientPlayers()
		{
		}

		public function find (id:int) :Player
		{
			return _dictionary[id] as Player;
		}

        public function findOwner (id:int) :Owner
        {
            const found:Player = find(id);
            if (found != null) {
                return found;
            }
            return Nobody.NOBODY;
        }

		public function register (player:Player) :void
		{
		    Log.debug(this + " registering " + player);
			_dictionary[player.id] = player;
			_list.push(player);
		}

        /**
         * Return true if there are no players on the same level as the one specified and within a certain radius.
         */
        public function playerAlone (player:Player) :Boolean
        {
            for each (var other:Player in _list) {
                if (other != player && other.levelNumber == player.levelNumber 
                    && other.position.distanceTo(player.position).length < Config.aloneRadius) {
                        return false;
                } 
            } 
            return true;
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