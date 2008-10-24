package client
{
	import arithmetic.BoardCoordinates;
	
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
		
        protected var _position:BoardCoordinates;
        protected var _client:Client;
	}
}