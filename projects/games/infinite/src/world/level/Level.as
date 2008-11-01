package world.level
{
	import arithmetic.BoardCoordinates;
	import arithmetic.BreadcrumbTrail;
	import arithmetic.CellIterator;
	import arithmetic.Vector;
	
	import server.Messages.CellUpdate;
	import server.Messages.LevelUpdate;
	import server.Messages.Neighborhood;
	import server.Messages.PlayerPosition;
	
	import world.Cell;
	import world.NeighborhoodBoard;
	import world.Player;
	import world.PlayerMap;
	import world.arbitration.BoardArbiter;
	import world.board.Board;
	
	public class Level
	{
		public var number:int;
		
		public function Level(number:int, height:int, starting:Board)		
		{
			this.number = number;
			_height = height;
			_board = new NeighborhoodBoard(starting);
			_arbiter = new BoardArbiter(_board);
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
            	player.cell = _board.cellAt(_board.startingPosition);
            } else {            
            	// otherwise iterate from there until we find a suitable cell
	        	var iterator:CellIterator= 
	        	   _board.cellAt(_board.startingPosition).iterator(_board, Vector.LEFT);
	        	   
	        	var cell:Cell;
	            do {
	            	cell = iterator.next();
	            	trace ("considering "+cell+" as starting point for "+player);
	            } 
	            while ( !cell.canBeStartingPosition || _players.occupying(cell.position))
	            
	            player.cell = cell;
            }
            
            // now that we've established the starting position, track the player.
            _players.trackPlayer(player);        	   
        }
                
        public function proposeMove (player:Player, coords:BoardCoordinates) :void
        {
        	_arbiter.proposeMove(player, _board.cellAt(coords));
        }
                
        public function toString () :String
        {
        	return "level "+number;
        }
        
        /**
         * Return a list of the players on this level.
         */
        public function get players () :Array
        {
        	return _players.list;
        }
        
        public function makeUpdate () :LevelUpdate
        {
        	const update:LevelUpdate = new LevelUpdate();
        	for each (var player:Player in players) {
        		update.add(new PlayerPosition(player.id, number, player.position));
        	} 
        	return update;
        }
        
        public function cellState (hood:Neighborhood) :CellUpdate
        {
        	return _board.neighborhood(hood);
        }
                
        protected var _explored:BreadcrumbTrail = new BreadcrumbTrail();
        protected var _arbiter:BoardArbiter;
        protected var _board:NeighborhoodBoard;
		protected var _height:int;
		protected var _players:PlayerMap = new PlayerMap();
		
		public static const DEFAULT_HEIGHT:int = 300;
	}
}
