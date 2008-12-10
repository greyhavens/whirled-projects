package client
{
	import client.player.*;
	
	import inventory.InventoryDisplay;
	
	import paths.Path;
	
	import world.ClientWorld;
	import world.arbitration.BoardArbiter;
	import world.board.*;
			
	public class PlayerController
	{
		public function PlayerController(world:ClientWorld, viewer:Viewer, players:ClientPlayers, player:Player, 
			inventoryDisplay:InventoryDisplay)
		{
			_world = world;
			_board = viewer.objective;
			_arbiter = new BoardArbiter(_board);
			_viewer = viewer;
			_players = players;
			_player = player;
			_viewer.playerController = this;			
		}

		public function handleCellClicked (event:CellEvent) :void
		{	
			//Log.debug("player controller handling click");		
			
			// check whether the player is in a cell they can't leave
			if (_player.cell != null && !_player.cell.leave) {
				return;
			}
			
			// if the player is already moving, then we don't care about exteraneous clicks here
			if (_player.isMoving()) {
				return;
			} 
			
			// tell the player a move is starting. The player will either receive back a path, or a path unavailable.
			_player.startMove();	
			Log.debug("proposing move");
			_world.proposeMove(event.cell.position);
			
			// at this point, if the player is alone, start the move anyway.
			Log.debug("checking whether player alone");
			if (_players.playerAlone(_player)) {			    
                const path:Path = _arbiter.findPath(_player, event.cell);
                if (path != null) {
                    Log.debug("player is alone so starting path before server responds");
                    _player.follow(path);
                }
            }
		}

        protected var _players:ClientPlayers;
        protected var _world:ClientWorld;
		protected var _arbiter:BoardArbiter;
		protected var _board:BoardInteractions	
		protected var _viewer:Viewer;
		protected var _player:Player;
	}
}