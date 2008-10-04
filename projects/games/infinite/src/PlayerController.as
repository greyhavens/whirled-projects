package
{
	import arbitration.BoardArbiter;
		
	public class PlayerController
	{
		public function PlayerController(
			frameTimer:FrameTimer, viewer:Viewer, player:PlayerCharacter, 
			inventory:Inventory)
		{
			_board = viewer.objective;
			_arbiter = new BoardArbiter(_board);
			_viewer = viewer;
			_player = player;
			_viewer.playerController = this;
			_player.playerController = this;
			
			frameTimer.addEventListener(FrameEvent.FRAME_START, handleFrameEvent);
			inventory.addEventListener(ItemEvent.ITEM_CLICKED, handleItemClicked);				
		}

		protected function handleFrameEvent (event:FrameEvent) :void
		{
			_player.handleFrameEvent(event);
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

			_arbiter.proposeMove(_player, event.cell);
		}

		public function handleItemClicked (event:ItemEvent) :void
		{
			const item:Item = event.item;
			trace ("clicked on "+item);
			if (_player.canUse(item)) {
				_player.makeUseOf(item);
				_player.hasUsed(item);
			}
		}

		protected var _arbiter:BoardArbiter;
		protected var _board:BoardInteractions	
		protected var _viewer:Viewer;
		protected var _player:PlayerCharacter;
	}
}