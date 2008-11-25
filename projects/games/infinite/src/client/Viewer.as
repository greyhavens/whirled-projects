package client
{
	import cells.CellBase;
	
	import client.player.Player;
	import client.radar.RadarView;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import server.Messages.CellState;
	import server.Messages.CellUpdate;
	
	import sprites.*;
	
	import world.NeighborhoodEvent;
	import world.board.*;
		
	public class Viewer extends Sprite
	{
	    // the position of the viewpoint in graphics coordinates
		public var viewPoint:Rectangle;
		
		public function Viewer(client:Client, width:int, height:int)
		{
			_client = client;
			
			SpriteUtil.addBackground(this, width, height, SpriteUtil.LIGHT_GREY);
			
			// set the position that will be used as a viewpoint
			viewPoint = new Rectangle(
				(width / 2) - (CellBase.UNIT.dx / 2),  	// center horizontally
				height - (CellBase.UNIT.dy * 2),        // two cells up vertically
				CellBase.UNIT.dx, 
				CellBase.UNIT.dy);

            _radarView = new RadarView(_client.radar);
            addChild(_radarView);
            _radarView.x = 475;
            _radarView.y = 5;         
		}
		
		/**
		 * Display the viewPoint for debugging purposes
		 */
		public function showViewPoint() :void
		{ 
			if (_viewPointShape == null) {
				const s:Shape = new Shape();
				with (s.graphics) {
					beginFill(0xFFFF00, 0.3);
					drawRect(0,0, viewPoint.width, viewPoint.height);
					endFill();		
				}
				addChild(s);
				s.x = viewPoint.x;
				s.y = viewPoint.y;
				_viewPointShape = s;
			}
		}
		
		public function showLevelComplete(levelNumber:int) :void
		{
		    if (_levelComplete == null) {
    		    _levelComplete = new LevelEndReward(levelNumber);		    
	   	        addChild(_levelComplete);
		        _levelComplete.y = 50;
		        _levelComplete.x = (width / 2) - (_levelComplete.width / 2);
                this.addEventListener(MouseEvent.CLICK, handleNextLevel);
            }
		}
		
		protected function handleNextLevel (event:MouseEvent) :void
		{
		    Log.debug("handling next level click");
		    this.removeEventListener(MouseEvent.CLICK, handleNextLevel);
		    if (_levelComplete != null) {
    		    if (contains(_levelComplete)) {
                    removeChild(_levelComplete);
                }
                _levelComplete = null;
            }
            _client.nextLevel();
		}
		
		/**
		 * Hide the viewPoint shape
		 */
		public function hideViewPoint() :void
		{
			if (_viewPointShape != null) {
				removeChild(_viewPointShape);
				_viewPointShape = null;
			}
		}
		
		public function set board (board:BoardInteractions) :void
		{			
			Log.debug("viewer width:"+width);
			_board = board;
						
			// create an objective that we can display
			if (_objective != null) {
			    _objective.destroy(_client.players);
				removeChild(_objective);
				_objective = null;				
			}
			_objective = new Objective(_client, this, board, board.startingPosition);
			
			_objective.addEventListener(NeighborhoodEvent.UNMAPPED, dispatchEvent);
			
			// add the objective 
			addChildAt(_objective, 0);

			// the viewpoint can be marked transparently for debugging
			if (Config.showViewPoint) {
				showViewPoint();
			}
		}
		
		public function updatedCells (update:CellUpdate) :void
		{
			_objective.updateCells(update);
		}

		public function updateCell (state:CellState) :void
		{
			_objective.updateCell(state);
		}

		public function get objective () :Objective 
		{
			return _objective;
		}
		
		public function set playerController (playerController:PlayerController) :void
		{
			_playerController = playerController;
		}
		
		public function handleCellClicked (event:CellEvent) :void
		{
			_playerController.handleCellClicked(event);
		}
		
		public function addPlayer (player:Player) :void
		{
			_objective.addPlayer(player);
		}
						
		public function addLocalPlayer (player:Player) :void
		{					    		    
			_objective.addLocalPlayer(player);
			_radarView.localPlayer = player;
		}
		
		public function removePlayer (player:Player) :void
		{
			// if the objective doesn't exist, the player is effectively 'removed' already.
			if (_objective == null) {
				return;
			}
			_objective.removePlayer(player);
		}
				
		protected var _radarView:RadarView;
		
		protected var _levelComplete:LevelEndReward;
			
		protected var _client:Client;
				
		protected var _playerController:PlayerController;
		
		// a shape for the viewpoint - to display for debugging or whatever
		protected var _viewPointShape:Shape; 

		// the board data
		protected var _board:BoardInteractions;
		
		// the part of reality that we can interact with
		protected var _objective:Objective;

		// the DPI of the screen
		protected const DPI:int = 96;
		
		// the distance of the eye from the screen
		protected const E:int = DPI * 18;
		
		// the distance of the objective from the viewer
		protected const D:int = DPI * 25; 
	}
}