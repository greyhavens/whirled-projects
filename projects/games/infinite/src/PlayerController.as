package
{
	import arithmetic.VoidBoardRectangle;
	
	public class PlayerController
	{
		public function PlayerController(
			frameTimer:FrameTimer, viewer:Viewer, player:PlayerCharacter, 
			inventory:Inventory)
		{
			_board = viewer.objective;
			_analyser = new BoardAnalyser(_board);
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
						
			// if the board tells us there is a clear path between here and the destination
			// we move sideways
			if (_analyser.hasSidewaysPath(_player.cell, event.cell)) {
				_player.moveSideways(event.cell);
				return;
			}
			
			// is the player above?
			if (_analyser.hasClimbingPath(_player.cell, event.cell)) {
				_player.climb(event.cell);
				return;
			}
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

		protected var _analyser:BoardAnalyser;
		protected var _board:BoardInteractions	
		protected var _viewer:Viewer;
		protected var _player:PlayerCharacter;
	}
}