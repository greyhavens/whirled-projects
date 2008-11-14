package client
{
	import client.player.*;
	
	import inventory.InventoryDisplay;
	
	import items.Item;
	
	import world.ClientWorld;
	import world.arbitration.BoardArbiter;
	import world.board.*;
			
	public class PlayerController
	{
		public function PlayerController(world:ClientWorld, viewer:Viewer, player:Player, 
			inventoryDisplay:InventoryDisplay)
		{
			_world = world;
			_board = viewer.objective;
			_arbiter = new BoardArbiter(_board);
			_viewer = viewer;
			_player = player;
			_viewer.playerController = this;			
		}

		public function handleCellClicked (event:CellEvent) :void
		{			
			// check whether the player is in a cell they can't leave
			if (_player.cell != null && !_player.cell.leave) {
				return;
			}
			
			// if the player is already moving, then we don't care about exteraneous clicks here
			if (_player.isMoving()) {
				return;
			} 
			
			_world.proposeMove(event.cell.position);
		}

        protected var _world:ClientWorld;
		protected var _arbiter:BoardArbiter;
		protected var _board:BoardInteractions	
		protected var _viewer:Viewer;
		protected var _player:Player;
	}
}