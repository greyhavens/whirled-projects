package client.player
{
	import arithmetic.BoardCoordinates;
	
	import client.Client;
	import client.Objective;
	
	import flash.events.EventDispatcher;
	
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
		
		public function enterLevel (level:int, position:BoardCoordinates) :void
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
        		
        protected var _cell:Cell;
        protected var _objective:Objective;
        protected var _position:BoardCoordinates;
        protected var _client:Client;
	}
}
