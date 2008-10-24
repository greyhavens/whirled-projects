package client
{
	import flash.events.EventDispatcher;
	
	import server.Messages.LevelEntered;
	
	import world.ClientWorld;
	import world.World;
	import world.WorldClient;
	import world.WorldListener;
	import world.level.LevelEvent;
	
	public class LocalWorld extends EventDispatcher implements ClientWorld, WorldListener
	{
		public function LocalWorld()
		{
			_world = new World();
			_world.addListener(this);
		}
		
		public function get worldType () :String
		{
			return "standalone";
		}
		
		public function enter (client:WorldClient) :void
		{
			_client = client;
			_world.playerEnters(ID);
		}

        public function get clientId () :int
        {
        	return ID;
        }
        
        /**
         * Inform the client that a player has entered a level.
         */ 
        public function handleLevelEntered(event:LevelEvent) :void
        {
            _client.levelEntered(
                new LevelEntered(event.player.id, event.level.number, event.player.position));
        }     
        	
        protected var _client:WorldClient;	
		protected var _world:World;
		
		// the local player is always ID 0.
		protected static const ID:int = 0;
	}
}