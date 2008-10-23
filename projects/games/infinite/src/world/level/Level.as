package world.level
{
	import arithmetic.CellIterator;
	import arithmetic.Vector;
	
	import world.Cell;
	import world.MutableBoard;
	import world.Player;
	import world.PlayerMap;
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
            if (_players.find(player.id) != null) {
            	throw new Error(player + " is already in "+this);
            }
            
            if (! _players.occupying(_board.startingPosition)) {
            	// if the starting position for the board is unoccupied, put the player there.
            	player.position = _board.startingPosition;
            } else {            
            	// otherwise iterate from there until we find a suitable cell
	        	var iterator:CellIterator= 
	        	   _board.cellAt(_board.startingPosition).iterator(_board, Vector.LEFT);
	        	   
	        	var cell:Cell;
	            do {
	            	cell = iterator.next();
	            } 
	            while ( !cell.canBeStartingPosition && ! _players.occupying(cell.position))
	            
	            player.position = cell.position;
            }
            
            // now that we've established the starting position, track the player.
            _players.trackPlayer(player);        	   
        }
                
        public function toString () :String
        {
        	return "level "+_number;
        }
                
        protected var _board:Board;
        protected var _number:int;
		protected var _height:int;
		protected var _players:PlayerMap = new PlayerMap();
		
		public static const DEFAULT_HEIGHT:int = 300;
	}
}
