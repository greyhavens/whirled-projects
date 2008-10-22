package world
{
	import flash.utils.Dictionary;
	
	public class Level
	{
		public function Level(number:int, height:int)		
		{
			_number = number;
			_height = height;
		}

		public function get height () :int
		{
			return _height;
		}

        /**
         * A player enters this level.
         */
        public function playerEnters (player:Player) :void
        {
            if (_players[player.id] != null) {
            	throw new Error(player + " is already in "+this);
            }        	
        	_players[player.id] = player;
        }
        
        public function toString () :String
        {
        	return "level "+_number;
        }
        
        protected var _number:int;
		protected var _height:int;
		protected var _players:Dictionary = new Dictionary();
		
		public static const DEFAULT_HEIGHT:int = 300;
	}
}
