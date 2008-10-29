package server
{
	import arithmetic.BoardCoordinates;
	
	import com.whirled.game.GameControl;
	import com.whirled.game.NetSubControl;
	import com.whirled.net.MessageReceivedEvent;
	
	import server.Messages.LevelEntered;
	import server.Messages.PathStart;
	
	import world.Player;
	import world.World;
	import world.WorldListener;
	import world.arbitration.MoveEvent;
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
		public function handleLevelEntered (event:LevelEvent) :void
		{
			// create the message
            const message:LevelEntered = 
                new LevelEntered(event.player.id, event.level.number, event.player.position);
                
            // who do we send the message to?
            sendToAll(RemoteWorld.LEVEL_ENTERED, message);
		}
		
		public function handlePathStart (event:MoveEvent) :void
		{
			const message:PathStart =
			     new PathStart(event.player.id, event.path);
			     
			sendToGroup(event.player.level.players, RemoteWorld.START_PATH, event.path);
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
				case MOVE_PROPOSED: moveProposed(event);
				case MOVE_COMPLETED: moveCompleted(event);
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
		
		protected function moveProposed (event:MessageReceivedEvent) :void
		{
			_world.moveProposed(event.senderId, event.value as BoardCoordinates);
		}
		
		protected function moveCompleted (event:MessageReceivedEvent) :void
		{
			_world.moveCompleted(event.senderId, event.value as BoardCoordinates);
		}
		
		/**
		 * Send a message with a payload to all clients.
		 */
		protected function sendToAll (message:int, payload:Object) :void
		{
			_net.sendMessage(String(message), payload)
		}
		
		protected function sendToGroup (group:Array, message:int, payload:Object) :void
		{
			for each (var player:Player in group) {
				_net.sendMessage(String(message), payload, player.id);
			}
		}
			
		protected var _world:World;
		protected var _net:NetSubControl;
		protected var _control:GameControl;
		
	    public static const CLIENT_ENTERS:int = 0;
	    public static const MOVE_PROPOSED:int = 1;
	    public static const MOVE_COMPLETED:int = 2;
	}
}