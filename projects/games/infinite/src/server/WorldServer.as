package server
{
	import com.whirled.game.GameControl;
	import com.whirled.game.NetSubControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import server.Messages.LevelEntered;
	
	import world.World;
	import world.WorldListener;
	import world.level.LevelEvent;
	
	public class WorldServer implements WorldListener
	{
		public function WorldServer(control:GameControl)
		{
            _world = new World();
            _world.addListener(this);
                        
			_control = control;
			_net = control.net;
	        _net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);		
		}
		
		/** 
		 * A user entered a level.  Send the appropriate messages to the clients.
		 */
		public function handleLevelEntered(event:LevelEvent) :void
		{
			// create the message
            const message:LevelEntered = 
                new LevelEntered(event.player.id, event.level.number, event.player.position);
                
            // who do we send the message to?
            sendToAll(RemoteWorld.LEVEL_ENTERED, message);
		}
		
		/**
		 * We received a message from one of the clients.  Identify it and initiate the appropriate
		 * action in the model.
		 */
		protected function handleMessageReceived(event:MessageReceivedEvent) :void
		{
			const message:int = int(event.name);
			switch (message) {
				case CLIENT_ENTERS: clientEnters(event);
			}			
			throw new Error(this+"don't understand message "+event.name+" from client "+event.senderId);
		}
		
		public function toString () :String
		{
			return "a world server";
		}
		
		/**
		 * Handle a message that a client has entered.
		 */
		protected function clientEnters (event:MessageReceivedEvent) :void
		{
	       _world.playerEnters(event.senderId);
		}
		
		/**
		 * Send a message with a payload to all clients.
		 */
		protected function sendToAll (message:int, payload:Object) :void
		{
			_net.sendMessage(String(message), payload)
		}
			
		protected var _world:World;
		protected var _net:NetSubControl;
		protected var _control:GameControl;
		
	    public static const CLIENT_ENTERS:int = 0; 
	}
}