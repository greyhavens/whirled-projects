package client
{
	import arithmetic.BoardCoordinates;
	
	public class LocalPlayer extends RemotePlayer implements Player
	{
		public function LocalPlayer(client:Client, id:int)
		{			
			super(client, id);
		}
		
		override public function enterLevel(level:int, position:BoardCoordinates) :void
		{
			// make sure the client is viewing the requested level.
			super.enterLevel(level, position);
            _client.selectLevel(level);
		}		
	}
}