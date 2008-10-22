package
{
	import actions.*;
	
	import arbitration.MovableCharacter;
	
	import arithmetic.*;
	
	import cells.CellInteractions;
	
    import client.FrameEvent;
    import client.Objective;
	import client.PlayerController;
	
	import flash.events.EventDispatcher;
	import flash.text.TextField;
	
	import inventory.InventoryDisplay;
	
	import items.Item;
	import items.ItemPlayer;
	
	import paths.Path;
	import paths.PathEvent;
	import paths.PathFollower;
	
	import sprites.PlayerSprite;
	
	import world.Cell;
	
	/**
	 * Represents the player who is using the console.
	 */
	public class PlayerCharacter extends EventDispatcher 
		implements CellInteractions, ItemPlayer, MoveInteractions, MovableCharacter, 
			PathFollower, Owner
	{
		public function PlayerCharacter(name:String, inventory:InventoryDisplay)
		{ 
			_name = name;
			_inventory = inventory;
			
			addEventListener(PathEvent.PATH_START, handlePathStart);
		}
			
		public function arriveInCell (cell:Cell) :void
		{
			_cell = cell;
			_cell.playerHasArrived(this);
			if (!cell.grip) {
				fall();
			}
		}
						
		/**
		 * Sets the objective in which this player is situated.
		 */
		public function set objective (objective:Objective) :void
		{
			_objective = objective;
			_cell = objective.getPlayerStartPosition();
			_objective.addEventListener(CellEvent.CELL_REPLACED, handleCellChanged);
		}
		
		protected function handleCellChanged (event:CellEvent) :void
		{
			if (_cell != null && _cell.position.equals(event.cell.position)) {
				_cell = event.cell;
			}
		}
				
		public function set playerController (playerController:PlayerController) :void
		{
			_playerController = playerController;
		}

		public function isMoving () :Boolean
		{
			return _playerAction != null;
		}
		
		public function actionComplete () :void
		{
			trace ("player action complete");
			_playerAction = null;
		}
		
		public function movementComplete () :void
		{			
			actionComplete();
		}
		
		/**
		 * Begin moving to the specified cell.  This assumes that there is already a clear
		 * path to the cell.
		 */
		public function moveSideways (destination:BoardCoordinates) :void
		{
			const newCell:Cell = cellAt(destination);
			trace("player move sideways from " + _cell + " to " + newCell);
			_playerAction = new MoveSideways(this, _objective, newCell);
		}
		
		/**
		 * Begin climbing to the specified cell.  This assumes that there is already a clear
		 * path to the cell.
		 */
		public function climb (destination:BoardCoordinates) :void
		{	
			const newCell:Cell = cellAt(destination);			
			trace("player climb from " + _cell + " to: " + newCell);
			_playerAction = new Climb(this, _objective, newCell);
		}		
		
		/**
		 * Begin falling.  This assumes that the player has entered a cell that affords no grip.
		 */
		public function fall () :void
		{
			_playerAction = new Fall(this, _objective);
		}
		
		public function teleport () :void
		{
			_playerAction = new Teleport(this, _objective);
		}
		
		public function handleFrameEvent (event:FrameEvent) :void
		{
			if (_playerAction != null) {			
				_playerAction.handleFrameEvent(event);
			}
		}
		
		public function canReceiveItem () :Boolean
		{
			return ! _inventory.isFull();
		}
		
		public function receiveItem (item:Item) :void
		{
			trace ("player received "+item);
			item.addToInventory(_inventory);
		}
		
		public function canUse (item:Item) :Boolean
		{
			return item.isUsableBy(this);	
		}
		
		public function makeUseOf (item:Item) :void
		{
			item.useBy(this);
		}
		
		public function hasUsed (item:Item) :void
		{
			trace ("player has used "+item);
			item.removeFromInventory(_inventory);
		}
		
		/**
		 * Return the cell that the player is currently 'occupying'.  Will return null if
		 * the player isn't in a cell.
		 */
		public function get cell () :Cell
		{
			return _cell;
		}
				
		public function cellAt (position:BoardCoordinates) :Cell
		{
			return _objective.cellAt(position);
		}
		
		public function replace (position:BoardCoordinates, newCell:Cell) :void
		{
			_objective.replace(position, newCell);
		}
		
		public function get name () :String
		{
			return _name;
		}
		
		/**
		 * Follow the specified path.
		 */
		public function follow (path:Path) :void
		{
			path.applyTo(this);
		}
		
		/**
		 * Handle the reception of a path event.
		 */
		public function handlePathStart(event:PathEvent) :void
		{
			follow(event.path);
		}
		
		protected var _inventory:InventoryDisplay;				
		protected var _playerAction:PlayerAction;
		protected var _playerController:PlayerController;
		protected var _objective:Objective;
		protected var _cell:Cell;
		protected var _name:String;
	}
}