package client
{
	import arithmetic.BoardCoordinates;
	import arithmetic.Geometry;
	import arithmetic.GraphicRectangle;
	
	import client.player.Player;
	import client.player.PlayerEvent;
	import client.radar.Radar;
	
	import com.whirled.game.NetSubControl;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import inventory.InventoryDisplay;
	
	import items.ItemFactory;
	
	import server.Messages.EnterLevel;
	import server.Messages.InventoryUpdate;
	import server.Messages.LevelComplete;
	import server.Messages.LevelUpdate;
	import server.Messages.PathStart;
	import server.Messages.PlayerPosition;
	import server.Messages.SabotageTriggered;
	
	import sprites.SpriteUtil;
	
	import world.ClientWorld;
	import world.DistributedBoard;
	import world.WorldClient;
	import world.board.*;
	
	public class Client extends Sprite implements WorldClient
	{
		public function Client(control:NetSubControl, world:ClientWorld)
		{
			_control = control;
			_world = world;
	
	        _radar = new Radar(7, 4);
	        		
			// set the overall size of the game
			SpriteUtil.addBackground(this, GAME_WIDTH, GAME_HEIGHT, SpriteUtil.GREY);
			this.x = 0;
			this.y = 0;			
			
			_viewer = new Viewer(this, 680, 420);
			
			_viewer.x = 10;
			_viewer.y = 10;
			addChild(_viewer);		
			
			_inventory = new InventoryDisplay(this, 580, 50);
			const invView:DisplayObject = _inventory.view;
			invView.x = 10;
			invView.y = 440;		
			addChild(invView);
			
			// position the height indicator beside the inventory
			_heightIndicator = new HeightIndicator();
			_heightIndicator.x = 590;
			_heightIndicator.y = 440;
			addChild(_heightIndicator);
			
			var frame:GraphicRectangle = GraphicRectangle.fromDisplayObject(this);
			
			const modeView:TextField = new TextField();
			modeView.text = mode + " mode";
			var rect:GraphicRectangle = GraphicRectangle.fromText(modeView).paddedBy(10).alignBottomRightTo(frame);		
			Geometry.position(modeView, rect.origin);
			addChild(modeView);
							
			_announcement = new Announcement(this);
			_announcement.y = GAME_HEIGHT-130;
			_announcement.x = 0;
			_announcement.width = GAME_WIDTH;
			 
			enterWorld();			
		}
						
		public function enterWorld () :void
		{
			_world.enter(this);
		}
										
		public function levelUpdate(update:LevelUpdate) :void
		{
			//Log.debug("processing level update");
			for each (var position:PlayerPosition in update.positions) {
				updatePosition(position);
			} 
		}
		
		public function enterLevel(detail:EnterLevel) :void
		{
			level(detail.level).height = detail.height;
			Log.debug("SETTING HEIGHT OF LEVEL: "+detail.level+" to "+detail.height);
			updatePosition(detail.position);
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
            	player = newPlayer(detail.userId, _world.nameForPlayer(detail.userId));
            	_players.register(player);
            }
            
            /**
             * Move the player to the appropriate level.
             */ 
            player.updatePosition(_board, detail);
		}
		
		/**
		 * Create a new player.
		 */
		protected function newPlayer(id:int, name:String) :Player
		{
			const player:Player = new Player(this, id, name);
            if (id == _world.clientId) {
            	_localPlayer = player;
            	_radar.player = player;
            }
            
            player.addEventListener(PlayerEvent.PATH_COMPLETED, handlePathComplete);
            player.addEventListener(PlayerEvent.PATH_COMPLETED, _radar.handlePathComplete);
                        
            // we care if any player changes level.
			player.addEventListener(PlayerEvent.CHANGED_LEVEL, handleChangedLevel);
			player.addEventListener(PlayerEvent.CHANGED_LEVEL, _radar.handleChangedLevel);
						
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
            	if (event.player.levelNumber == _level) {
            		_viewer.addPlayer(event.player);
            	} else {
            		_viewer.removePlayer(event.player);
            	}
            }
		}
		
		protected function handlePathComplete (event:PlayerEvent) :void
		{
			var player:Player = event.player;
			
			// if the completion is for the local player, then we need to inform the server			
			if (event.player == _localPlayer) {
	            const finish:BoardCoordinates = event.player.path.finish; 
	            _world.moveComplete(finish);
	            _viewer.objective.pathComplete(player);
	            const height:int = player.position.y;
	            _heightIndicator.current = height;
	        } else {
                _viewer.objective.pathComplete(player);	        	
	        }
		}
		
		/** 
		 * The local player has just completed a level. 
		 */
		public function levelComplete (detail:LevelComplete) :void
		{
		    if (detail.player == _localPlayer.id) {
    		    Log.debug(this+" level complete");
	       	    _viewer.showLevelComplete(_localPlayer.levelNumber);
	        }
		}
		
		/**
		 * Called to cause the player to move to the next level (results from clicking on the next level indicator)
		 */
		public function nextLevel() :void
		{
		    _world.nextLevel();
		}
				
		/**
		 * Cause the client to start displaying a new level.
		 */
		public function selectLevel (player:Player) :void
		{
			Log.debug(this+" selecting level "+player.levelNumber);
			
			// if the client is already displaying the requested level, return.
			if (_level == player.levelNumber) {
				return;
			}
						
			// we can start off with the default blank board.
			_board = new DistributedBoard(_players, this, new BlankBoard(player.levelNumber, height), _control);	
            _heightIndicator.top = _board.height;
            
            Log.debug(this+" created "+_board);
                 
			// and assign a new board to the view.
			_viewer.board = _board;

            // we need to notify the player that we've just moved them onto another board.
            player.moveToBoard(_board);

            _controller = new PlayerController(_world, _viewer, _players, _localPlayer, _inventory);
            
			_level = player.levelNumber;
						
			// add the players we know about on this level
			_viewer.addLocalPlayer(_localPlayer);
			for each (var p:Player in _players.list) {
				if (p.levelNumber == player.levelNumber) {
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
            if (player.levelNumber == _localPlayer.levelNumber) {
                player.follow(detail.path);
            }
		}
						
		public function receiveItem(detail:InventoryUpdate) :void
		{
			_inventory.addItemAt (detail.position, _itemFactory.makeItem(detail.attributes));
		}     
		
		public function itemClicked (position:int) :void
		{
			Log.debug(this+" clicked item at "+position);
			_world.useItem(position);
		}

		public function itemUsed (position:int) :void
		{
			_inventory.removeItemAt(position);
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
		
		public function get player () :Player
		{
			return _localPlayer;
		}
		
		public function pathUnavailable () :void
		{
			_localPlayer.noPath();
		}
		
		public function level (number:int) :ClientLevel
		{
		    return new ClientLevel(_control, number);
		}
		
		public function get players () :ClientPlayers
		{
		    return _players;
		}
		
		public function get radar () :Radar
		{
		    return _radar;
		}
		
		public function sabotageTriggered (detail:SabotageTriggered) :void
		{
		    if (detail.victimId == _localPlayer.id) {
                _announcement.positive();		        
		        _announcement.announcement = "Drat! " + _world.nameForPlayer(detail.saboteurId) 
		          + " " + detail.type + " you!";
		        _announcement.show();
		    }
		    
		    if (detail.saboteurId == _localPlayer.id) {
		        _announcement.negative();
		        _announcement.announcement = "Cool! You " + detail.type + " " 
		          + _world.nameForPlayer(detail.victimId) + "!";
		        _announcement.show();
		    }
		}
		
		protected var _control:NetSubControl;				
		protected var _levels:Array = new Array();		
		protected var _serverOffset:Number = 0;
		
		protected var _announcement:Announcement;		
		protected var _localPlayer:Player;
		protected var _world:ClientWorld;
		protected var _players:ClientPlayers = new ClientPlayers();
		protected var _level:int = NO_LEVEL;
		
		protected var _controller:PlayerController;
		protected var _board:DistributedBoard;
		protected var _viewer:Viewer;
		protected var _inventory:InventoryDisplay;
		protected var _heightIndicator:HeightIndicator;
		protected var _radar:Radar;
		
		protected var _itemFactory:ItemFactory = new ItemFactory();
		
		protected const GAME_WIDTH:int = 700;
		protected const GAME_HEIGHT:int = 500;
				
		protected static const NO_LEVEL:int = -1;
	}	
}
