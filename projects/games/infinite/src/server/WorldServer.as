package server
{
	import arithmetic.BoardCoordinates;
	
	import com.whirled.game.GameControl;
	import com.whirled.game.NetSubControl;
	import com.whirled.game.OccupantChangedEvent;
	import com.whirled.game.StateChangedEvent;
	import com.whirled.net.MessageReceivedEvent;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import interactions.SabotageEvent;
	
	import server.Messages.CellState;
	import server.Messages.EnterLevel;
	import server.Messages.InventoryUpdate;
	import server.Messages.LevelComplete;
	import server.Messages.MoveProposal;
	import server.Messages.Neighborhood;
	import server.Messages.PathStart;
	import server.Messages.PlayerPosition;
	import server.Messages.SabotageTriggered;
	import server.Messages.Serializable;
	
	import world.CellStateEvent;
	import world.InventoryEvent;
	import world.Player;
	import world.World;
	import world.WorldListener;
	import world.arbitration.MoveEvent;
	import world.level.Level;
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
	        _batcher = new MessageBatcher(_net);
	        _batcher.start();
	        
	        _scoreKeeper = new ScoreKeeper(this, _control.game);
	        
	        _control.game.addEventListener(StateChangedEvent.GAME_STARTED, reportEvent);
            _control.game.addEventListener(StateChangedEvent.GAME_ENDED, reportEvent);
            _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, reportEvent);
            _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, reportEvent);
            _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);
		}
		
		protected function handleOccupantLeft (event:OccupantChangedEvent) :void
		{
			if (_control.game.getOccupantIds().length < 1) {
				_scoreKeeper.endGame();
			}
		}
		
		protected function reportEvent(event:Event) :void
		{
			Log.debug("EVENT RECEIVED: "+event.type);
		}
		
		/** 
		 * A user entered a level.  Send the appropriate messages to the clients.
		 */
		public function handleLevelEntered (event:LevelEvent) :void
		{
			// create the message
            const message:EnterLevel =
                new EnterLevel(event.level.levelNumber, event.level.height, 
                    new PlayerPosition(event.player.id, event.level.levelNumber, event.player.position));
                
            // who do we send the message to?
            sendToAll(RemoteWorld.LEVEL_ENTERED, message);
            send(event.player.id, RemoteWorld.LEVEL_UPDATE, event.level.makeUpdate());
            if (event.level.levelNumber > 1) {
            	const text:String = event.player.name + 
                    " just reached level "+event.level.levelNumber+"!";
                systemMessage(text);
            }
		}
		
		public function handleLevelComplete (event:LevelEvent) :void
		{
		    const message:LevelComplete = new LevelComplete(event.player.id, event.level.levelNumber);
		    sendToAll(RemoteWorld.LEVEL_COMPLETE, message);
//		    sendToGroup(event.level.players, RemoteWorld.LEVEL_COMPLETE, message);
		    _scoreKeeper.levelComplete(event.player.id, event.level.levelNumber);
		}
		
		public function handlePathStart (event:MoveEvent) :void
		{
			const message:PathStart =
			     new PathStart(event.player.id, event.path);
		  
		    const level:Level = _world.findLevel(event.player.levelNumber);		 
		  
		    sendToAll(RemoteWorld.START_PATH, message);
//			sendToGroup(level.players, RemoteWorld.START_PATH, message);
		}
		
		public function handleNoPath (event:MoveEvent) :void
		{
			signalClient(event.player.id, RemoteWorld.PATH_UNAVAILABLE);
		}
		
		public function handleCellStateChange (event:CellStateEvent) :void
		{
			const message:CellState = event.cell.state;	
			sendToAll(RemoteWorld.UPDATED_CELL, message);					
			//sendToGroup(event.level.players, RemoteWorld.UPDATED_CELL, message);
		}
		
		/**
		 * We received a message from one of the clients.  Identify it and initiate the appropriate
		 * action in the model.
		 */
		protected function handleMessageReceived(event:MessageReceivedEvent) :void
		{
			// drop messages that we sent
			if (event.senderId == id) {
				return;
			}
			
			const message:int = int(event.name);
            Log.debug(this+" received a "+messageName[message]+" message from client "+event.senderId);

			switch (message) {
				case CLIENT_ENTERS: return clientEnters(event);
				case MOVE_PROPOSED: return moveProposed(event);
				case MOVE_COMPLETED: return moveCompleted(event); 
				case REQUEST_CELLS: return requestCells(event);
				case USE_ITEM: return useItem(event);
				case NEXT_LEVEL: return nextLevel(event);
			}			
			throw new Error(this+"don't understand message "+event.name+" from client "+event.senderId);
		}
		
		public function toString () :String
		{
			return "world server";
		}
		
		/**
		 * Handle a message that a client has entered.
		 */
		protected function clientEnters (event:MessageReceivedEvent) :void
		{
		    sendTime(event.senderId);			
	        _world.playerEnters(event.senderId, _control.game.getOccupantName(event.senderId));
		}

        protected function nextLevel (event:MessageReceivedEvent) :void
        {
            _world.nextLevel(event.senderId);
        }
		
		protected function moveProposed (event:MessageReceivedEvent) :void
		{
			Log.debug("move proposed");
			_world.moveProposed(event.senderId, MoveProposal.readFromArray(event.value as ByteArray));
		}
		
		protected function moveCompleted (event:MessageReceivedEvent) :void
		{
			_world.moveCompleted(event.senderId, BoardCoordinates.readFromArray(event.value as ByteArray));
		}
		
		protected function requestCells (event:MessageReceivedEvent) :void
		{
            sendToAll(RemoteWorld.UPDATED_CELLS, 
               _world.cellState(event.senderId, Neighborhood.readFromArray(event.value as ByteArray)));         
//			send(event.senderId, RemoteWorld.UPDATED_CELLS, 
//			   _world.cellState(event.senderId, Neighborhood.readFromArray(event.value as ByteArray)));			
		}
		
		protected function useItem (event:MessageReceivedEvent) :void
		{
			_world.useItem(event.senderId, event.value as int);
		}		
		
		/**
		 * Send a time sync message to a single client.
		 */
		protected function sendTime(id:int) :void
		{		    
			_net.sendMessage(REMOTE_TIME_SYNC, (new Date()).getTime(), id);
		}
		
		protected function signalClient(id:int, message:int) :void
		{
            _batcher.sendMessage(String(message), null, id);
			//_net.sendMessage(String(message), null, id);
		}
		
		/**
		 * Send a message to a single client.
		 */
		protected function send(id:int, message:int, payload:Serializable) :void
		{
            _batcher.sendMessage(String(message), payload.writeToArray(new ByteArray()), id);
			//_net.sendMessage(String(message), payload.writeToArray(new ByteArray()), id);
		}
		
		/**
		 * Send a message with a payload to all clients.
		 */
		protected function sendToAll (message:int, payload:Serializable) :void
		{
            _batcher.sendMessage(String(message), payload.writeToArray(new ByteArray()));
			//_net.sendMessage(String(message), payload.writeToArray(new ByteArray()));
		}
		
//		/**
//		 * Send a message with a payload to a single client.
//		 */
//		protected function sendToGroup (group:Array, message:int, payload:Serializable) :void
//		{
//			for each (var player:Player in group) {
//				_net.sendMessage(String(message), payload.writeToArray(new ByteArray()), player.id);
//			}
//		}
			
		public function handleItemReceived (event:InventoryEvent) :void
		{
			send(event.player.id, RemoteWorld.ITEM_RECEIVED, new InventoryUpdate(event.position, event.item.attributes));
		}		
			
		public function handleItemUsed (event:InventoryEvent) :void
		{
			_net.sendMessage(String(RemoteWorld.ITEM_USED), event.position, event.player.id);
		}
		
		public function handleSabotageTriggered (event:SabotageEvent) :void
		{
		    // do nothing if you are using your own trap.
		    if (event.victimId == event.sabotage.saboteurId) {
		        return;
		    }
		    
		    const victim:Player = _world.findPlayer(event.victimId);
		    const saboteur:Player = _world.findPlayer(event.sabotage.saboteurId);
		    
		    const detail:SabotageTriggered = new SabotageTriggered(event.victimId, event.sabotage.saboteurId, event.sabotage.sabotageType);
		    send(event.victimId, RemoteWorld.SABOTAGE_TRIGGERED, detail);
		    send(event.sabotage.saboteurId, RemoteWorld.SABOTAGE_TRIGGERED, detail);		    
		    
		    systemMessage(victim.name +" was "+ event.sabotage.sabotageType + " by "+saboteur.name);
		    _scoreKeeper.movePoints(event.sabotage.saboteurId, event.victimId, 1); 
		}		
		
		public function findPlayer(id:int) :Player
		{
			return _world.findPlayer(id);
		}
			
		protected function get id () :int
		{
			return _control.game.getMyId();
		}
		
		public function systemMessage (text:String) :void
	    {
	        _control.game.systemMessage(text);
	    }
			
		protected var _world:World;
		protected var _scoreKeeper:ScoreKeeper;
		protected var _net:NetSubControl;
		protected var _control:GameControl;
		protected var _batcher:MessageBatcher;
		
	    public static const CLIENT_ENTERS:int = 0;
	    public static const MOVE_PROPOSED:int = 1;
	    public static const MOVE_COMPLETED:int = 2;
        public static const REQUEST_CELLS:int = 3;
        public static const USE_ITEM:int = 4;
        public static const NEXT_LEVEL:int = 5;
        
        // No point in stringifying this every time we want to synchronize the clock.
        public static const REMOTE_TIME_SYNC:String = String(RemoteWorld.TIME_SYNC);

	    public static const messageName:Dictionary = new Dictionary();
	    
	    messageName[CLIENT_ENTERS] = "client enters";
	    messageName[MOVE_PROPOSED] = "move proposed";
	    messageName[MOVE_COMPLETED] = "move completed";
	    messageName[REQUEST_CELLS] = "request cells";
	    messageName[USE_ITEM] = "use item";
	    messageName[NEXT_LEVEL] = "next level";
	}
}