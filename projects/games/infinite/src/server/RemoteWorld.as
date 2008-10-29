package server
{
	import arithmetic.BoardCoordinates;
	
	import com.whirled.game.GameControl;
	import com.whirled.game.NetSubControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import server.Messages.LevelEntered;
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
		}		

        public function get worldType () :String
        {
        	return "shared";
        }
        
        public function handleMessageReceived (event:MessageReceivedEvent) :void
        {
        	const message:int = int(event.name);
            switch (message) {
                case LEVEL_ENTERED: levelEntered(event);
                case START_PATH: pathStart(event);
            }       
            throw new Error(this+"doesn't understand message "+event.name+" from client "+event.senderId);            
        }
        
        public function levelEntered (event:MessageReceivedEvent) :void
        {
            _client.levelEntered(LevelEntered.readFromArray(event.value as ByteArray));
        }        
        
        public function pathStart (event:MessageReceivedEvent) :void
        {
        	_client.startPath(PathStart.readFromArray(event.value as ByteArray));
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
        
        public function proposeMove (coords:BoardCoordinates) :void
        {
        	sendToServer(WorldServer.MOVE_PROPOSED, coords);
        }

        public function moveComplete (coords:BoardCoordinates) :void
        {
        	sendToServer(WorldServer.MOVE_COMPLETED, coords);
        }

        /**
         * Send a simple 'signal' to the server.  This is numbered message with no data payload.
         */ 
        protected function signalServer(message:int) :void
        {
        	_net.sendMessage(String(message), null, NetSubControl.TO_SERVER_AGENT);
        }

        /**
         * Send a message with a payload to the server.
         */ 
        protected function sendToServer(message:int, data:Serializable) :void
        {
        	trace ("sending to server "+data);
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
	}
}