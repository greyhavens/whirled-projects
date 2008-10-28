package world
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.EventDispatcher;
		
    import world.arbitration.MoveEvent;
	import world.level.LevelEvent;
	import world.level.LevelRegister;	
	
	/**
	 * This is the actual implementation of the game world.  It is instantiated on the server if
	 * the game is running in multi-player mode, or on the client if it's running in standalone mode.
	 */
	public class World extends EventDispatcher
	{
		public function World()
		{
			_players = new PlayerRegister();
			_levels = new LevelRegister();
		}
		
		public function addListener (listener:WorldListener) :void
		{
            addEventListener(LevelEvent.LEVEL_ENTERED, listener.handleLevelEntered);
            addEventListener(MoveEvent.PATH_START, listener.handlePathStart);		
		}
		
		/**
		 * A player enters the world.
		 */
		public function playerEnters (id:int) :void
		{
	       // when a player enters, we need to decide whether they are already in the game.
            var player:Player = _players.find(id);
            if (player == null) {
            	player = newPlayer(id);
            }
		}
		
		/**
		 * A proposal is made for a player to move.
		 */
		public function moveProposed (id:int, coords:BoardCoordinates) :void
		{
			var player:Player = _players.find(id);
			if (player == null) {
				throw new Error("move to "+coords+" proposed for unknown player "+id); 
			}
			
			player.proposeMove(coords);
		}
		
		/**
		 * Create a new player.
		 */
		public function newPlayer (id:int) :Player
		{
			// construct the player object.
			const player:Player = new Player(id);
			
			// redispatch events from players
		    player.addEventListener(LevelEvent.LEVEL_ENTERED, dispatchEvent);
		    player.addEventListener(PlayerEvent.MOVE_COMPLETED, dispatchEvent);
		    player.addEventListener(MoveEvent.PATH_START, dispatchEvent);
		    		    
		    // register the player and place them on the first level.
            _levels.playerEnters(player);
            _players.register(player);
            return player;
		}		
				
		protected var _levels:LevelRegister;
		protected var _players:PlayerRegister;
	}
}