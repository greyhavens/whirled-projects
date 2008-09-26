package
{
	import actions.*;
	
	import arithmetic.*;
	
	import cells.CellInteractions;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import items.ItemPlayer;
	
	import sprites.PlayerSprite;
	
	/**
	 * Represents the player who is using the console.
	 */
	public class PlayerCharacter implements Character, CellInteractions, ItemPlayer, MoveInteractions
	{
		public function PlayerCharacter(name:String, inventory:Inventory)
		{ 
			_name = name;
			_inventory = inventory;
		}
		
		public function get view () :DisplayObject
		{
			if (_view == null) {
				_view = createView();
			}
			return _view;
		}
		
		public function createView () :PlayerSprite
		{
			return new PlayerSprite();
		}
		
		protected function createTestView() :DisplayObject
		{
			var s:Sprite = new Sprite();
			var r:Shape = new Shape();
			
			with (r.graphics) {
				beginFill(0x808000, 1);
				drawRect(0,0, 20,60);
				endFill();
			}
			
			var l:TextField = new TextField();
			with (l) {
				text = _name;
			 	width = textWidth;
				height = textHeight;
			}
			
			s.addChild(l);												
			s.addChild(r);
			
			// position the symbolic rectange below and centered on the name
			r.y = l.textHeight;
			if (l.textWidth > r.width) {
				r.x = (l.textWidth/2) - (r.width/2);
			}						
			return s;
		}
			
		public function arriveInCell (cell:Cell) :void
		{
			_cell = cell;
			positionInCell(_cell.position).applyTo(view);
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
		
		/**
		 * Return the graphics coordinates that puts the player at their resting position within
		 * the cell.
		 */
		public function positionInCell (cell:BoardCoordinates) :GraphicCoordinates
		{
			const v:DisplayObject = view;
			const cellPos:GraphicCoordinates = _objective.cellCoordinates(cell);
			return new GraphicCoordinates(
				cellPos.x + (Config.cellSize.dx / 2) - (v.width / 2),
				cellPos.y + (Config.cellSize.dy - v.height)
			);
		}
		
		public function cellBoundary() :GraphicCoordinates
		{
			const v:DisplayObject = view;
			return new GraphicCoordinates(
				v.x - ((Config.cellSize.dx / 2) - (v.width / 2)),
				v.y - (Config.cellSize.dy - v.height) 
			);
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
		public function moveSideways (newCell:Cell) :void
		{
			trace("player move sideways from " + _cell + " to " + newCell);
			_playerAction = new MoveSideways(this, _objective, newCell);
		}
		
		/**
		 * Begin climbing to the specified cell.  This assumes that there is already a clear
		 * path to the cell.
		 */
		public function climb (newCell:Cell) :void
		{
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
		
		protected var _inventory:Inventory;				
		protected var _playerAction:PlayerAction;
		protected var _playerController:PlayerController;
		protected var _objective:Objective;
		protected var _cell:Cell;
		protected var _view:DisplayObject;
		protected var _name:String;
	}
}