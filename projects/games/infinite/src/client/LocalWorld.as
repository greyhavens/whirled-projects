package client
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.EventDispatcher;
	
	import server.Messages.LevelEntered;
	import server.Messages.PathStart;
	
	import world.ClientWorld;
	import world.World;
	import world.WorldClient;
	import world.WorldListener;
	import world.arbitration.MoveEvent;
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
		
        public function get clientId () :int
        {
            return ID;
        }
        
        public function enter (client:WorldClient) :void
        {
            _client = client;
            _world.playerEnters(ID);
        }
        
        /**
         * Inform the client that a player has entered a level.
         */ 
        public function handleLevelEntered(event:LevelEvent) :void
        {
            _client.levelEntered(
                new LevelEntered(event.player.id, event.level.number, event.player.position));
        }     
        
        public function proposeMove (coords:BoardCoordinates) :void
        {
            _world.moveProposed(ID, coords);
        }

        public function handlePathStart (event:MoveEvent) :void
        {
        	_client.startPath(new PathStart(event.player.id, event.path));
        }        
                	
        public function moveComplete (coords:BoardCoordinates) :void
        {
        	_world.moveCompleted(ID, coords);
        }
                	
        protected var _client:WorldClient;	
		protected var _world:World;
		
		// the local player is always ID 0.
		protected static const ID:int = 0;
	}
}