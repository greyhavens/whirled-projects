package client.player
{
	import arithmetic.BoardCoordinates;
	
	import client.Client;
	import client.Objective;
	
	import flash.events.EventDispatcher;
	
	import paths.Path;
	
	import server.Messages.PlayerPosition;
	
	import world.Cell;
	import world.arbitration.MovablePlayer;
	import world.board.BoardAccess;
	
	public class Player extends EventDispatcher implements MovablePlayer
	{		
		public function Player (client:Client, id:int)
		{			
			_client = client;
			_id = id;
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
		public function moveToBoard (board:BoardAccess) :void
		{
			_cell = board.cellAt(_position);			
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
        }
        		
        public function isMoving () :Boolean
        {
        	return _moving;
        }
        
        public function follow (path:Path) :void
        {
        	Log.debug(this+" setting path to "+path);
        	_path = path;
            dispatchEvent(new PlayerEvent(PlayerEvent.PATH_STARTED, this));
            _moving = true;
        }
                
        public function get path () :Path
        {
        	return _path;
        }
                
        public function pathComplete () :void
        {
            dispatchEvent(new PlayerEvent(PlayerEvent.PATH_COMPLETED, this));
            _moving = false;
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
                
        protected var _moving:Boolean = false;
        protected var _levelNumber:int;
        protected var _id:int;
        protected var _path:Path;		
        protected var _cell:Cell;
        protected var _objective:Objective;
        protected var _position:BoardCoordinates;
        protected var _client:Client;
	}
}
