package world.level
{
	import flash.utils.Dictionary;
	
	import world.MutableBoard;
	import world.Player;
	import world.board.Board;
	
	public class Level
	{
		public function Level(number:int, height:int, starting:Board)		
		{
			_number = number;
			_height = height;
			_board = new MutableBoard(starting);
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
        	// blow up if the player has already entered.
            if (_players[player.id] != null) {
            	throw new Error(player + " is already in "+this);
            }
            
            // remember this player.
        	_players[player.id] = player;
        	
        	// now assign the player a starting location
        }
        
        public function toString () :String
        {
        	return "level "+_number;
        }
                
        protected var _board:Board;
        protected var _number:int;
		protected var _height:int;
		protected var _players:Dictionary = new Dictionary();
		
		public static const DEFAULT_HEIGHT:int = 300;
	}
}
