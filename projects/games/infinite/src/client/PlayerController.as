package client
{
	import client.player.*;
	
	import inventory.InventoryDisplay;
	
	import items.Item;
	import items.ItemEvent;
	
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
			
			inventoryDisplay.addEventListener(ItemEvent.ITEM_CLICKED, handleItemClicked);
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

        /**
         * When an item is clicked, we forward the message to the 
         */ 
		public function handleItemClicked (event:ItemEvent) :void
		{
			// can't use items while the player is moving.
			if (_player.isMoving()) {
				return;
			}
			const item:Item = event.item;
			trace ("clicked on "+item);
//			if (_player.canUse(item)) {
//				_player.makeUseOf(item);
//				_player.hasUsed(item);
//			}
		}

        protected var _world:ClientWorld;
		protected var _arbiter:BoardArbiter;
		protected var _board:BoardInteractions	
		protected var _viewer:Viewer;
		protected var _player:Player;
	}
}