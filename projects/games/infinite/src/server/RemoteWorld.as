package server
{
	import arithmetic.BoardCoordinates;
	
	import com.whirled.game.GameControl;
	import com.whirled.game.NetSubControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import server.Messages.CellState;
	import server.Messages.CellUpdate;
	import server.Messages.EnterLevel;
	import server.Messages.InventoryUpdate;
	import server.Messages.LevelComplete;
	import server.Messages.LevelUpdate;
	import server.Messages.MoveProposal;
	import server.Messages.Neighborhood;
	import server.Messages.PathStart;
	import server.Messages.Serializable;
	
	import world.ClientWorld;
	import world.WorldClient;

    /**
     * Represents a connection between a single client and the world.
     */ 
	public class RemoteWorld extends EventDispatcher implements ClientWorld
	{
		public function RemoteWorld(gameControl:GameControl)
		{
			_gameControl = gameControl;
			_net = _gameControl.net; 
			_net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);
			Log.debug("--- SESSION STARTED ---");
		}		

        public function get worldType () :String
        {
        	return "shared";
        }
        
        public function handleMessageReceived (event:MessageReceivedEvent) :void
        {
        	const message:int = int(event.name);
        	Log.debug("received message "+messageName[message]+" from server ");
            switch (message) {
                case LEVEL_ENTERED: return levelEntered(event);
                case START_PATH: return pathStart(event);
                case LEVEL_UPDATE: return levelUpdate(event);
                case UPDATED_CELLS: return updatedCells(event);
                case TIME_SYNC: return timeSync(event);
                case UPDATED_CELL: return updateCell(event);
                case ITEM_RECEIVED: return itemReceived(event);
                case ITEM_USED: return itemUsed(event);
                case PATH_UNAVAILABLE: return pathUnavailable(event);
            }       
            throw new Error(this+"doesn't understand message "+event.name+" from client "+event.senderId);            
        }
        
        public function levelEntered (event:MessageReceivedEvent) :void
        {
            _client.enterLevel(EnterLevel.readFromArray(event.value as ByteArray));
        }        
        
        public function pathStart (event:MessageReceivedEvent) :void
        {
        	_client.startPath(PathStart.readFromArray(event.value as ByteArray));
        }
        
        public function levelUpdate (event:MessageReceivedEvent) :void
        {
        	_client.levelUpdate(LevelUpdate.readFromArray(event.value as ByteArray));
        }        
        
        public function levelComplete (event:MessageReceivedEvent) :void
        {
            _client.levelComplete(LevelComplete.readFromArray(event.value as ByteArray));
        }
        
        public function updatedCells (event:MessageReceivedEvent) :void
        {
        	_client.updatedCells(CellUpdate.readFromArray(event.value as ByteArray));
        }
        
        public function updateCell (event:MessageReceivedEvent) :void
        {
        	_client.updateCell(CellState.readFromArray(event.value as ByteArray));
        }
        
        public function itemReceived (event:MessageReceivedEvent) :void
        {
        	_client.receiveItem(InventoryUpdate.readFromArray(event.value as ByteArray));
        }
        
        public function itemUsed (event:MessageReceivedEvent) :void
        {
        	_client.itemUsed(event.value as int);
        }
        
        public function pathUnavailable (event:MessageReceivedEvent) :void
        {
        	_client.pathUnavailable();
        }
        
        /**
         * Deal with a time sync message from the server.  The 'value' associate with a time
         * sync is just a number representing the current server time.
         */ 
        public function timeSync (event:MessageReceivedEvent) :void
        {
        	_client.timeSync(event.value as Number);
        }
        
        override public function toString () :String
        {
            return "world client for "+_gameControl.player;
        }
        
        /**
         * The client attempts to enter the world.
         */
        public function enter (client:WorldClient) :void
        {
        	// remember the client
        	_client = client;
        	signalServer(WorldServer.CLIENT_ENTERS);        
        }
        
        public function nextLevel () :void
        {
            signalServer(WorldServer.NEXT_LEVEL);
        }
        
        public function useItem (position:int) :void
        {
        	_net.sendMessage(String(WorldServer.USE_ITEM), position, NetSubControl.TO_SERVER_AGENT);
        }
        
        public function proposeMove (coords:BoardCoordinates) :void
        {
        	sendToServer(WorldServer.MOVE_PROPOSED, new MoveProposal(_client.serverTime, coords));
        }

        public function moveComplete (coords:BoardCoordinates) :void
        {
        	sendToServer(WorldServer.MOVE_COMPLETED, coords);
        }

        public function requestCellUpdate (hood:Neighborhood) :void
        {
        	sendToServer(WorldServer.REQUEST_CELLS, hood);
        }

        /**
         * Send a simple 'signal' to the server.  This is numbered message with no data payload.
         */ 
        protected function signalServer(message:int) :void
        {
        	Log.debug ("sending signal "+message+" to server");
        	_net.sendMessage(String(message), null, NetSubControl.TO_SERVER_AGENT);
        }

        /**
         * Send a message with a payload to the server.
         */ 
        protected function sendToServer(message:int, data:Serializable) :void
        {
        	Log.debug ("sending message "+message+" to server with data "+data);
        	_net.sendMessage(String(message), data.writeToArray(new ByteArray()),
        	    NetSubControl.TO_SERVER_AGENT);
        }

        public function get clientId () :int
        {        	
        	return _gameControl.game.getMyId();
        }

        protected var _client:WorldClient;
        protected var _gameControl:GameControl;
        protected var _net:NetSubControl;
        
        /**
         * Messages that remote clients can receive from the server.
         */ 
        public static const LEVEL_ENTERED:int = 0;
        public static const START_PATH:int = 1;
        public static const LEVEL_UPDATE:int = 2;
        public static const UPDATED_CELLS:int = 3;
        public static const TIME_SYNC:int = 4;
        public static const UPDATED_CELL:int = 5;
        public static const ITEM_RECEIVED:int = 6;
        public static const ITEM_USED:int = 7;
        public static const PATH_UNAVAILABLE:int = 8;
        public static const LEVEL_COMPLETE:int = 9;
        
        public static const messageName:Dictionary = new Dictionary();
        messageName[LEVEL_ENTERED] = "level entered";
        messageName[START_PATH] = "start path";
        messageName[LEVEL_UPDATE] = "level update";
        messageName[UPDATED_CELLS] = "updated cells";
        messageName[TIME_SYNC] = "time sync";
        messageName[UPDATED_CELL] = "updated cell";
        messageName[ITEM_RECEIVED] = "item received";
        messageName[ITEM_USED] = "item used";
        messageName[PATH_UNAVAILABLE] = "path unavailable";
        messageName[LEVEL_COMPLETE] = "level compete";        
	}
}