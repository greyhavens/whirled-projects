package server
{
	import com.whirled.game.GameControl;
	import com.whirled.game.NetSubControl;
	
	import flash.events.EventDispatcher;
	
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
			_netControl = _gameControl.net; 
		}

        public function get worldType () :String
        {
        	return "shared";
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
        
        /**
         * Send a simple 'signal' to the server.  This is numbered message with no data payload.
         */ 
        protected function signalServer(message:int) :void
        {
        	sendToServer(message, null);
        }

        /**
         * Send a message with a payload to the server.
         */ 
        protected function sendToServer(message:int, data:Object) :void
        {
        	_netControl.sendMessage(String(message), data, NetSubControl.TO_SERVER_AGENT);
        }

        protected var _client:WorldClient;
        protected var _gameControl:GameControl;
        protected var _netControl:NetSubControl;
	}
}