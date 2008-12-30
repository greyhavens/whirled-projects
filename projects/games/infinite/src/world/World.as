package world
{
	import arithmetic.BoardCoordinates;
	
	import com.whirled.game.NetSubControl;
	
	import flash.events.EventDispatcher;
	
	import interactions.SabotageEvent;
	
	import server.Messages.MoveProposal;
	
	import world.arbitration.MoveEvent;
	import world.level.Level;
	import world.level.LevelEvent;
	import world.level.LevelRegister;	
	
	/**
	 * This is the actual implementation of the game world.  It is instantiated on the server if
	 * the game is running in multi-player mode, or on the client if it's running in standalone mode.
	 */
	public class World extends EventDispatcher 
	{
		public function World(control:NetSubControl)
		{
			_players = new PlayerRegister();
			_levels = new LevelRegister(this, control);
		}
		
		public function addListener (listener:WorldListener) :void
		{
            addEventListener(LevelEvent.LEVEL_ENTERED, listener.handleLevelEntered);
            addEventListener(LevelEvent.LEVEL_COMPLETE, listener.handleLevelComplete);
            addEventListener(MoveEvent.PATH_START, listener.handlePathStart);
            addEventListener(MoveEvent.PATH_UNAVAILABLE, listener.handleNoPath);
            addEventListener(InventoryEvent.RECEIVED, listener.handleItemReceived);
            addEventListener(InventoryEvent.USED, listener.handleItemUsed);
            addEventListener(SabotageEvent.TRIGGERED, listener.handleSabotageTriggered);
		}
		
		/**
		 * A player enters the world.
		 */
		public function playerEnters (id:int, name:String) :void
		{
	       // when a player enters, we need to decide whether they are already in the game.
            var player:Player = _players.find(id);
            if (player == null) {
            	player = newPlayer(id, name);
            }
		}
		
		public function nextLevel (id:int) :void
		{
		    var player:Player = _players.find(id);
		    if (player != null) {
		        _levels.nextLevel(player);
		    }
		}
		
		/**
		 * A proposal is made for a player to move.
		 */
		public function moveProposed (id:int, proposal:MoveProposal) :void
		{
			var player:Player = _players.find(id);
			if (player == null) {
				throw new Error("move to "+proposal.coordinates+" proposed for unknown player "+id); 
			}
			player.proposeMove(proposal.coordinates);
		}
		
		public function moveCompleted (id:int, coords:BoardCoordinates) :void
		{
		    Log.debug(this + " received move complete");
			var player:Player = _players.find(id);
			if (player == null) {
				throw new Error("move to " +coords+" proposed for unknown player "+id);
			}
			player.moveComplete(coords);
		}
		
		public function useItem (id:int, position:int) :void
		{
			var player:Player = _players.find(id);
			if (player == null) {
				throw new Error("use item "+position+" requested for unknown player "+id);				
			}
			player.useItem(position);
		}
		
		/**
		 * Create a new player.
		 */
		public function newPlayer (id:int, name:String) :Player
		{
			// construct the player object.
			const player:Player = new Player(id, name);
			
			// redispatch events from players
		    player.addEventListener(LevelEvent.LEVEL_ENTERED, dispatchEvent);
		    player.addEventListener(LevelEvent.LEVEL_COMPLETE, dispatchEvent);
		    player.addEventListener(PlayerEvent.MOVE_COMPLETED, dispatchEvent);
		    player.addEventListener(MoveEvent.PATH_START, dispatchEvent);
		    player.addEventListener(InventoryEvent.RECEIVED, dispatchEvent);
            player.addEventListener(InventoryEvent.USED, dispatchEvent);
            player.addEventListener(MoveEvent.PATH_UNAVAILABLE, dispatchEvent);
            player.addEventListener(SabotageEvent.TRIGGERED, dispatchEvent);
            		    		    
		    // register the player and place them on the first level.
            _players.register(player);
            _levels.playerEnters(player);
            return player;
		}		
						
		public function distributeState (level:Level, cell:Cell) :void
		{
			dispatchEvent(new CellStateEvent(CellStateEvent.STATE_CHANGED, level, cell));
		}
		
		public function findLevel (level:int) : Level
		{
			return _levels.find(level);
		}
						
		public function findPlayer (player:int) :Player
		{
		    return _players.find(player);
		}
						
		protected var _levels:LevelRegister;
		protected var _players:PlayerRegister;
	}
}