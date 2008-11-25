package client.player
{
	import arithmetic.BoardCoordinates;
	
	import client.Client;
	import client.Objective;
	
	import flash.events.EventDispatcher;
	
	import items.ItemPlayer;
	
	import paths.Path;
	
	import server.Messages.PlayerPosition;
	
	import world.Cell;
	import world.arbitration.MovablePlayer;
	import world.board.BoardAccess;
	import world.board.BoardInteractions;
	
	public class Player extends EventDispatcher implements MovablePlayer, ItemPlayer
	{		
		public function Player (client:Client, id:int, name:String)
		{			
			_client = client;
			_id = id;
			_name = name;
		}
		
		public function updatePosition (board:BoardAccess, position:PlayerPosition) :void
		{
			if (position.level != levelNumber) {
				enterLevel(board, position.level, position.position);
			} else {
				_position = position.position;
                _cell = board.cellAt(position.position);
			}
		}
		
		protected function enterLevel (board:BoardAccess, level:int, position:BoardCoordinates) :void
		{
			_levelNumber = level;
			_position = position;
			dispatchEvent(new PlayerEvent(PlayerEvent.CHANGED_LEVEL, this));
		}
		
		/**
		 * Move this player to the same coordinates on another board.
		 */
		public function moveToBoard (board:BoardInteractions) :void
		{
			_board = board;
			cell = board.cellAt(_position);			
		}
		
        public function get position () :BoardCoordinates
        {
        	return _position;
        }
        
        public function get cell () :Cell
        {
        	return _cell;
        }
        		
        public function set cell (cell:Cell) :void
        {
        	_cell = cell;
        	_position = _cell.position;
            Log.debug("updated position of "+this+" to "+_position);
        }
        		
        public function isMoving () :Boolean
        {
        	return _moving;
        }

        /**
         * Called when a move starts.  This is in anticipation of receiving a path back from the board. 
         */
        public function startMove () :void
        {
        	_moving = true;
        }
        
        public function follow (path:Path) :void
        {
        	_path = path;
            dispatchEvent(new PlayerEvent(PlayerEvent.PATH_STARTED, this));
        }
                
        public function get path () :Path
        {
        	return _path;
        }
                
        public function pathComplete () :void
        {
            _moving = false;
            dispatchEvent(new PlayerEvent(PlayerEvent.PATH_COMPLETED, this));
        }
        
        override public function toString () :String
        {
        	return "player "+_id;
        }
         
        public function get id () :int
        {
        	return _id;
        }
         
        public function get levelNumber () :int
        {
        	return _levelNumber;
        }
        
        public function cellAt (coords:BoardCoordinates) :Cell
        {
        	return _board.cellAt(coords);
        }
        
        public function get name () :String
        {
            return _name;
        }
        
        public function get startingPosition () :BoardCoordinates
        {
        	return _board.startingPosition;
        }                
        
        public function replace (cell:Cell) :void
        {
            throw new Error("cells cannot be replaced on the client");        	
        }
        
        public function teleport () :void
        {
        	throw new Error("teleport (or any other action) cannot be carried out on the server");
        }
        
        /**
         * Handle the situation that a requested path is not available.
         */
        public function noPath () :void
        {
            Log.debug(this + " received message that proposed path is unavailable.  Clearing movement and path");
        	_moving = false;
        	_path = null;
        }
                
        protected var _board:BoardInteractions;
        protected var _moving:Boolean = false;
        protected var _levelNumber:int;
        protected var _id:int;
        protected var _path:Path;		
        protected var _cell:Cell;
        protected var _position:BoardCoordinates;
        protected var _client:Client;
        protected var _name:String;
	}
}
