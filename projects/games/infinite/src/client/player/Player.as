package client.player
{
	import arithmetic.BoardCoordinates;
	import arithmetic.VoidBoardRectangle;
	
	import client.Client;
	import client.Objective;
	
	import flash.events.EventDispatcher;
	
	import paths.Path;
	
	import server.Messages.PlayerPosition;
	
	import world.Cell;
	
	public class Player extends EventDispatcher
	{
		public var id:int;
		public var level:int;
		
		public function Player (client:Client, id:int)
		{
			_client = client;
			this.id = id;
		}
		
		public function updatePosition (position:PlayerPosition) :void
		{
			if (position.level != level) {
				enterLevel(position.level, position.position);
			} else {
				_position = position.position;
			}
		}
		
		protected function enterLevel (level:int, position:BoardCoordinates) :void
		{
			this.level = level;
			_position = position;
			dispatchEvent(new PlayerEvent(PlayerEvent.CHANGED_LEVEL, this));
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
        	return false;
        }
        
        public function follow (path:Path) :void
        {
        	Log.debug(this+" setting path to "+path);
        	_path = path;
            dispatchEvent(new PlayerEvent(PlayerEvent.PATH_STARTED, this));
        }
                
        public function get path () :Path
        {
        	return _path;
        }
                
        public function pathComplete () :void
        {
            dispatchEvent(new PlayerEvent(PlayerEvent.PATH_COMPLETED, this));
        }

        public function clearPath () :void
        {
        	Log.debug(this+" clearing path (was "+path+")");
        	_path = null;
        }
        
        override public function toString () :String
        {
        	return "player "+id;
        }
                
        protected var _path:Path;		
        protected var _cell:Cell;
        protected var _objective:Objective;
        protected var _position:BoardCoordinates;
        protected var _client:Client;
	}
}
