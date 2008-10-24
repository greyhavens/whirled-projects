package client
{
	import arithmetic.BoardCoordinates;
	
	import world.Cell;
	import world.board.BoardAccess;
	
	public class RemotePlayer implements Player
	{
		public var id:int;
		public var level:int;
		
		public function RemotePlayer (client:Client, id:int)
		{
			_client = client;
			this.id = id;
		}
		
		public function enterLevel (level:int, position:BoardCoordinates) :void
		{
			this.level = level;
			_position = position;
		}
		
		public function get cell () :Cell
		{
			return _objective.cellAt(_position);
		}	

        public function set objective (objective:Objective) :void
        {
            _objective = objective;         
        }
        
        protected var _objective:Objective;
        protected var _position:BoardCoordinates;
        protected var _client:Client;
	}
}
