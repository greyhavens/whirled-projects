package client
{
	import arithmetic.Geometry;
	import arithmetic.GraphicRectangle;
	
	import client.player.Player;
	import client.player.PlayerEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import inventory.InventoryDisplay;
	
	import server.Messages.CellUpdate;
	import server.Messages.LevelUpdate;
	import server.Messages.PathStart;
	import server.Messages.PlayerPosition;
	
	import sprites.SpriteUtil;
	
	import world.ClientWorld;
	import world.MutableBoard;
	import world.NeighborhoodEvent;
	import world.WorldClient;
	import world.board.*;
	import world.level.*;
	
	public class Client extends Sprite implements WorldClient
	{
		public function Client(world:ClientWorld)
		{
			_world = world;
			
			// set the overall size of the game
			SpriteUtil.addBackground(this, GAME_WIDTH, GAME_HEIGHT, SpriteUtil.GREY);
			this.x = 0;
			this.y = 0;			
			
			_viewer = new Viewer(this, 680, 420);
			_viewer.addEventListener(NeighborhoodEvent.UNMAPPED, handleUnmappedNeighborhood);
			
			_viewer.x = 10;
			_viewer.y = 10;
			addChild(_viewer);		
			
			_inventory = new InventoryDisplay(680, 50);
			const invView:DisplayObject = _inventory.view;
			invView.x = 10;
			invView.y = 440;			
			addChild(invView);
			
			var frame:GraphicRectangle = GraphicRectangle.fromDisplayObject(this);
			
			const modeView:TextField = new TextField();
			modeView.text = mode + " mode";
			var rect:GraphicRectangle = GraphicRectangle.fromText(modeView).paddedBy(10).alignBottomRightTo(frame);		
			Geometry.position(modeView, rect.origin);
			addChild(modeView);
				
			enterWorld();			
		}
						
		public function enterWorld () :void
		{
			_world.enter(this);
		}
										
		public function levelUpdate(update:LevelUpdate) :void
		{
			Log.debug("processing level update");
			for each (var position:PlayerPosition in update.positions) {
				updatePosition(position);
			} 
		}
		
		/**
		 * Receive a message that a player has entered a level.
		 */
		public function updatePosition(detail:PlayerPosition) :void
		{
			Log.debug("handling position update "+detail);
			// find the player
			var player:Player = _players.find(detail.userId);
		     
            // if we don't already know about the player, create a new one.
            if (player == null)
            {
            	player = newPlayer(detail.userId);
            	_players.register(player);
            }
            
            /**
             * Move the player to the appropriate level.
             */ 
            player.updatePosition(detail);
		}
		
		/**
		 * Create a new player.
		 */
		protected function newPlayer(id:int) :Player
		{
			const player:Player = new Player(this, id);
            if (id == _world.clientId) {
            	_localPlayer = player;
            	
            	// we only care about path completed events from the local player
                player.addEventListener(PlayerEvent.PATH_COMPLETED, handlePathComplete);            
            }
            // we care if any player changes level.
			player.addEventListener(PlayerEvent.CHANGED_LEVEL, handleChangedLevel);
		    return player;
		}
		
		protected function handleChangedLevel (event:PlayerEvent) :void
		{
			// if it's the local player, then switch level to the player's new
			// level.
			if (event.player == _localPlayer) {
    			selectLevel (event.player);
            } else {
            	// otherwise, if the player has entered the level that the local
            	// player is on, then 
            	if (event.player.level == _level) {
            		_viewer.addPlayer(event.player);
            	} else {
            		_viewer.removePlayer(event.player);
            	}
            }
		}
		
		protected function handlePathComplete (event:PlayerEvent) :void
		{
			_world.moveComplete(event.player.path.finish);
            _viewer.objective.pathComplete(event.player.path);
			event.player.clearPath();
		}
		
		protected function handleUnmappedNeighborhood (event:NeighborhoodEvent) :void
		{
			_world.requestCellUpdate(event.hood);
		}
		
		/**
		 * Cause the client to start displaying a new level.
		 */
		public function selectLevel (player:Player) :void
		{
			Log.debug(this+" selecting level "+player.level);
			
			// if the client is already displaying the requested level, return.
			if (_level == player.level) {
				return;
			}
			
			// we can start off with the default blank board.
			_board = new MutableBoard(new BlankBoard);
            Log.debug(this+" created "+_board);       
            
                 
			// and assign a new board to the view.
			_viewer.board = _board;

            // update cells - this is bad encapsulation since the order of these operations
            // relies on knowing the fact that assigning the board to the viewer causes the
            // objective to be created which is a precondition for handing a cell update
            _world.requestCellUpdate(player.position.vicinity.neighborhood);

            _controller = new PlayerController(_world, _viewer, _localPlayer, _inventory);
            
			_level = player.level;
			
			// add the players we know about on this level
			_viewer.addLocalPlayer(_localPlayer);
			for each (var p:Player in _players.list) {
				if (p.level == player.level) {
					_viewer.addPlayer(p);
				}
			}
		}
		
		public function get mode () :String 
		{
			return _world.worldType;
		}
		
		public function startPath (detail:PathStart) :void
		{
            const player:Player = _players.find(detail.userId);
            player.follow(detail.path);
		}
		
		public function updatedCells (detail:CellUpdate) :void
		{
			Log.debug("client processing "+detail);
			_viewer.updatedCells(detail);
		}
		
		override public function toString () :String
		{
			return "client "+_world.clientId; 
		}
				
		/**
		 * Return our best estimate of the time on the server.
		 */
		public function get serverTime () :Number
		{
			const current:Date = new Date();
			return current.getTime() + _serverOffset;
		}
			
		/**
		 * Update our view of the time on the server based on an 'up-to-date' reading of the 
		 * server clock (network lag permitting).
		 */	
		public function timeSync (serverTime:Number) :void
		{
			const current:Date = new Date();
			_serverOffset = serverTime - current.getTime();
		}
				
		protected var _serverOffset:Number = 0;
		
		protected var _localPlayer:Player;
		protected var _world:ClientWorld;
		protected var _players:PlayerRegister = new PlayerRegister();
		protected var _level:int = NO_LEVEL;
		
		protected var _controller:PlayerController;
		protected var _board:BoardInteractions;
		protected var _viewer:Viewer;
		protected var _inventory:InventoryDisplay;
		
		protected const GAME_WIDTH:int = 700;
		protected const GAME_HEIGHT:int = 500;
				
		protected static const NO_LEVEL:int = -1;
	}	
}