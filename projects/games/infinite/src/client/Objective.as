package client
{
	import arithmetic.*;
	
	import cells.CellObjective;
	import cells.ViewFactory;
	import cells.views.CellView;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import graphics.Diagram;
	import graphics.OwnerLabel;
	
	import sprites.PlayerSprite;

	/**
	 * The objective is a renderable sprite combining all of the objects necessary to display
	 * the playfield into a single instance.  The objective may also contain off-screen objects that
	 * are prepared for later display.
	 */
	public class Objective extends Sprite implements BoardInteractions, CellObjective, Diagram, CellMemory
	{
		public function Objective(
			viewer:Viewer, board:Board, startingPosition:BoardCoordinates)
		{
			_viewer = viewer;
			
			// make a copy of the viewer size, because otherwise the objective
			// itself will cause the viewer to grow.
			pixelWidth = _viewer.width;
			pixelHeight = _viewer.height;
			
			_board = board;
			_boxController = new BoxController(_board);
			
			
			if (Config.distributeFruitMachines) {
				_cells = new CellScrollBuffer(this, _boxController);
			} else {
				_cells = new CellScrollBuffer(this, _board);
			}

			CELL_MARGINS = computeMarginWidths();						
			
			// Most of the time there isn't a lot of change in the objective itself.
			// only really when we add rows or columns
			// so it almost certainly does improve performance if we cache it most of the time.
			cacheAsBitmap = true;
			
			// Create a new OwnerLable() and add it to the top of the display list.
			_label = new OwnerLabel(this);
			addChild(_label);
			
			_viewFactory = new ViewFactory(); 
		}		
		
		public function scrollViewPointToPlayer () :void
		{
			scrollViewPointTo(_playerView.cellBoundary());
		}
		
		/**
		 * Scroll the objective so that the viewpoint is at the provided coordinates which
		 * are relative to the origin of the objective.
		 */
		public function scrollViewPointTo (coords:GraphicCoordinates) :void
		{
			scrollRect = new Rectangle(
				coords.x - _viewer.viewPoint.x,
				coords.y - _viewer.viewPoint.y,
				pixelWidth,
				pixelHeight
			);
			
			const newCoords:BoardCoordinates = boardCoordinates(coords);
			const surround:BoardRectangle = boardSurround(newCoords);
			_cells.shiftBufferTo(surround);
			
//			_cells.shiftBufferTo(boardSurround(boardCoordinates(coords)));				
		}

		/**
		 * Return the coordinates relative to the objective itself of the point that will be 
		 * displayed at the center of the current image.
		 */ 
		public function get centerOfView () :GraphicCoordinates 
		{
			return new GraphicCoordinates(scrollRect.x + (scrollRect.width / 2), 
					scrollRect.y + (scrollRect.height / 2));
		}

		public function get visibleArea () :GraphicRectangle
		{
			return GraphicRectangle.fromRectangle(scrollRect); 
		}

		/**
		 * Return the distance to a given display object from the center of the current view.
		 */
		public function centerTo (targetPoint:GraphicCoordinates) :Vector
		{
			return centerOfView.distanceTo(targetPoint);
		}

		protected function boardCoordinates (coords:GraphicCoordinates) :BoardCoordinates
		{
			return coords.boardCoordinates(_cells.origin, _origin);
		}

		/**
		 * Compute the widths of the margins around the viewpoint in cells that we need to have on
		 * the origin to keep things operating smoothly
		 */
		protected function computeMarginWidths () :Object
		{
			const margins:Object = {
				top: (_viewer.viewPoint.y / Config.cellSize.dy) + 0.5 + BORDER,
				bottom: ((_viewer.height - _viewer.viewPoint.y)
					/ Config.cellSize.dy) - 0.5 + BORDER,
				left: (_viewer.viewPoint.x / Config.cellSize.dx) + 0.5 + BORDER,
				right:((_viewer.width - _viewer.viewPoint.x)
					/ Config.cellSize.dx) - 0.5 + BORDER
			}
			
			// dimensions must include the viewpoint square itself
			margins.width = margins.left + margins.right + 1;
			margins.height = margins.top + margins.bottom + 1;
						
			return margins;
		}
		
		/**
		 * Display a cell at the appropriate coordinates within the objective.
		 */
		public function showCell (c:Cell) :void 
		{
			const v:CellView = _viewFactory.viewOf(c);
			v.addToObjective(this);
			_viewBuffer.store(c.position, v);	
			v.addEventListener(CellEvent.CELL_CLICKED, handleCellClicked);				
		}
		
		/**
		 * Stop displaying the given cell.  After this is done, the view associated with the cell
		 * is no longer used and may be discarded.
		 */
		public function hideCell (c:Cell) :void
		{
			_viewBuffer.take(c.position).removeFromObjective(this);
		}
		
		public function displayOwnership (cell:Cell) :void
		{
			trace ("showing user that this is "+cell.owner.name+"'s "+cell.objectName);
			const view:CellView = _viewBuffer.find(cell.position);
			if (view is Labellable) {
				_label.displayOwnership(view as Labellable);
			}
		}
				
		public function hideOwnership (labellable:Cell) :void
		{
			trace ("hiding from user that this is "+labellable.owner.name+"'s "+labellable.objectName);			
			_label.hide();
		}
				
		/**
		 * Compute a rectangle in board coordinates that will mean the viewpoint square can be
		 * scrolled to and the rest of the viewer will be fully tiled.
		 */ 
		protected function boardSurround (viewPoint:BoardCoordinates) :BoardRectangle
		{
			return new BoardRectangle(
				viewPoint.x - CELL_MARGINS.left,
				viewPoint.y - CELL_MARGINS.top,
				CELL_MARGINS.width,
				CELL_MARGINS.height
			);
		}
		
		protected function handleCellClicked(event:CellEvent) :void
		{
			_viewer.handleCellClicked(event);
			trace("clicked on "+event.cell);
		}		
		
		public function set player (player:PlayerCharacter) :void
		{
			_player = player;
			player.objective = this;
			_playerView = new PlayerSprite(player);
			bufferViewpoint(player.cell.position);		
			scrollViewPointTo(cellCoordinates(player.cell.position));
			addChild(_playerView);
			Geometry.position(_playerView, _playerView.positionInCell(this, player.cell.position));
		}
			
		protected function bufferViewpoint (viewPoint:BoardCoordinates) :void
		{
			const rect:BoardRectangle = boardSurround(viewPoint);
			_origin = new GraphicCoordinates(0,0);
			_cells.initializeWith(rect);
		}
		
		public function cellCoordinates (position:BoardCoordinates) :GraphicCoordinates
		{
			return position.graphicsCoordinates(_cells.origin, _origin);
		}
						
		/**
		 * Return a starting cell suitable for a new player.
		 */
		public function getPlayerStartPosition() :Cell
		{
			return _cells.cellAt(new BoardCoordinates(_board.startingPosition.x, _board.startingPosition.y));
		}

		/**
		 * Return the cell at a given point in the board coordinates.  Returns the live cell that
		 * is part of the objective if the cell is in play, otherwise returns an inactive one from
		 * the board.
		 */
		public function cellAt (position:BoardCoordinates) :Cell
		{
			return _cells.cellAt (position);
		}
		
		public function remember (cell:Cell) :void
		{
			_memory.remember(cell);
		}

		/**
		 * Recall the cell associated with the supplied position from the memory.  Does not refer
		 * to the board or other sources.
		 */
		public function recall (position:BoardCoordinates) :Cell
		{
			return _memory.recall(position);
		}
	
		public function forget (cell:Cell) :void
		{
			_memory.forget(cell);
		}
	
		/**
		 * Replace a cell at a given position with the new cell that is supplied.
		 * TODO: REPLACE THIS WITH REAL PERSISTENCE TO THE BOARD
		 */
		public function replace (position:BoardCoordinates, newCell:Cell) :void
		{
			cellAt(position).removeFromObjective();
			remember(newCell);
			newCell.addToObjective(this);
			dispatchEvent(new CellEvent(CellEvent.CELL_REPLACED, newCell));
		}
		
		public function get playerView () :PlayerSprite 
		{
			return _playerView;
		}
	
	    protected var _playerView:PlayerSprite;
	
		protected var _viewFactory:ViewFactory;
		// owner label
		protected var _label:OwnerLabel;
	
		// the viewer
		protected var _viewer:Viewer;
			
		// a representation of the player character 
		protected var _player:PlayerCharacter;
		
		// memory for cell state that should be kept off the board.
		protected var _memory:CellMemory = new CellDictionary();
				
		// memory associating views with cells.
		protected var _viewBuffer:ViewBuffer = new ViewBuffer();
				
		// buffer of cells
		protected var _cells:CellScrollBuffer;
			
		// the coordinates within the origin sprite at which the cell at the top left
		// of the cell buffer is drawn
		protected var _origin:GraphicCoordinates;
				
		// The box controller is responsible for placing boxes onto the board when there are not
		// enough to keep the action going.
		protected var _boxController:BoxController;		
				
		protected var _board:Board;		
		
		// width and height in board cells computed by dividing the pixel size by the tile size
		// and assuming whole cells with no bleed.
		protected var W:int;
		protected var H:int;
		
		protected var pixelWidth:int; 
		protected var pixelHeight:int;

		// number of cells surrounding the board
		protected static const BORDER:int = 2;
		
		// the number of cells surrounding the viewpoint in each direction
		// (top, bottom, left, right)
		protected var CELL_MARGINS:Object;		
	}
}