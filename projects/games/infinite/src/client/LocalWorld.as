package client
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.EventDispatcher;
	
	import server.Messages.EnterLevel;
	import server.Messages.InventoryUpdate;
	import server.Messages.MoveProposal;
	import server.Messages.Neighborhood;
	import server.Messages.PathStart;
	import server.Messages.PlayerPosition;
	
	import world.CellStateEvent;
	import world.ClientWorld;
	import world.InventoryEvent;
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
        	Log.debug("player entering world");
            _client = client;
            _world.playerEnters(ID);
        }
        
        /**
         * Inform the client that a player has entered a level.
         */ 
        public function handleLevelEntered(event:LevelEvent) :void
        {
            _client.enterLevel(new EnterLevel(event.player.level.number, event.player.level.height,                
                new PlayerPosition(event.player.id, event.level.number, event.player.position)));
        }     
        
        public function proposeMove (coords:BoardCoordinates) :void
        {
            _world.moveProposed(ID, new MoveProposal(_client.serverTime, coords));
        }

        public function handlePathStart (event:MoveEvent) :void
        {
        	_client.startPath(new PathStart(event.player.id, event.path));
        }        
                	
        public function moveComplete (coords:BoardCoordinates) :void
        {
        	_world.moveCompleted(ID, coords);
        }
        
        public function requestCellUpdate (hood:Neighborhood) :void
        {        
        	_client.updatedCells(_world.cellState(ID, hood));        	
        }
        
        public function handleCellStateChange (event:CellStateEvent) :void
        {
        	_client.updateCell(event.cell.state);
        }
            
        public function handleItemReceived (event:InventoryEvent) :void
        {
        	_client.receiveItem(new InventoryUpdate(event.position, event.item.attributes));
        }        
                	
        public function useItem (position:int) :void
        {
        	_world.useItem(ID, position);
        }
                	
  		public function handleItemUsed (event:InventoryEvent) :void
  		{
  			_client.itemUsed(event.position);
  		}
         
        public function handleNoPath (event:MoveEvent) :void
        {
        	_client.pathUnavailable();
        }
                	
        protected var _client:WorldClient;	
		protected var _world:World;
		
		// the local player is always ID 0.
		protected static const ID:int = 0;
	}
}