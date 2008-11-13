package client
{
	import arithmetic.*;
	
	import cells.CellObjective;
	import cells.ViewFactory;
	import cells.views.CellView;
	
	import client.player.Player;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import graphics.Diagram;
	import graphics.OwnerLabel;
	
	import paths.Path;
	
	import server.Messages.CellState;
	import server.Messages.CellUpdate;
	import server.Messages.Neighborhood;
	
	import sprites.PlayerSprite;
	import sprites.ViewEvent;
	
	import world.BoxController;
	import world.Cell;
	import world.Chronometer;
	import world.NeighborhoodEvent;
	import world.board.*;
    
	/**
	 * The objective is a renderable sprite combining all of the objects necessary to display
	 * the playfield into a single instance.  The objective may also contain off-screen objects that
	 * are prepared for later display.
	 */
	public class Objective extends Sprite implements BoardInteractions, CellObjective, Diagram
	{
		public function Objective(
			clock:Chronometer, viewer:Viewer, board:BoardInteractions, 
			startingPosition:BoardCoordinates)
		{
			_clock = clock;
			_viewer = viewer;
			
			// make a copy of the viewer size, because otherwise the objective
			// itself will cause the viewer to grow.
			pixelWidth = _viewer.width;
			pixelHeight = _viewer.height;
			
			_board = board;			
			
    		_cells = new CellScrollBuffer(this, _board);

			CELL_MARGINS = computeMarginWidths();						
			
			// Most of the time there isn't a lot of change in the objective itself.
			// only really when we add rows or columns
			// so it almost certainly does improve performance if we cache it most of the time.
			cacheAsBitmap = true;
			
			// Create a new OwnerLable() and add it to the top of the display list.
			_label = new OwnerLabel(this);
			addChild(_label);
			
			_viewFactory = new ViewFactory(); 
			
			initializeViewpoint(startingPosition);
			_frameTimer.start();
		}		
		
//		public function scrollViewPointToPlayer () :void
//		{
//			scrollViewPointTo(_playerView.cellBoundary());
//		}
		
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
			const v:CellView = _viewFactory.viewOf(c, _clock.serverTime);
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
			Log.debug ("showing user that this is "+cell.owner.name+"'s "+cell.objectName);
			const view:CellView = _viewBuffer.find(cell.position);
			if (view is Labellable) {
				_label.displayOwnership(view as Labellable);
			}
		}

		public function hideOwnership (labellable:Cell) :void
		{
			Log.debug ("hiding from user that this is "+labellable.owner.name+"'s "+labellable.objectName);			
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
			Log.debug("clicked on "+event.cell);
		}		
				
		/**	
		 * Initialize the bugger, positioning the specificed point at the viewpoint.
		 */
		protected function initializeViewpoint (viewPoint:BoardCoordinates) :void
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
		 * Return the cell at a given point in the board coordinates.  Returns the live cell that
		 * is part of the objective if the cell is in play, otherwise returns an inactive one from
		 * the board.
		 */
		public function cellAt (position:BoardCoordinates) :Cell
		{
			return _cells.cellAt (position);
		}
				
		/**
		 * Replace a cell at a given position with the new cell that is supplied.
		 * TODO: REPLACE THIS WITH REAL PERSISTENCE TO THE BOARD
		 */
		public function replace (newCell:Cell) :void
		{
			cellAt(newCell.position).removeFromObjective();
			newCell.addToObjective(this);
			dispatchEvent(new CellEvent(CellEvent.CELL_REPLACED, newCell));
		}
		
	    /**
	     * Add a local player to the level that this objective is currently associated with, displaying
	     * the player at the focus of the camera immediately.  The camera will normally track this
	     * player from that point forward.
	     */
	    public function addLocalPlayer (player:Player) :void
	    { 	    	
	    	const sprite:PlayerSprite = addPlayer(player);
	    	follow(sprite);
	    }
	    
	    public function pathComplete (path:Path) :void
        {
        	const unmapped:Neighborhood = _breadcrumbs.visit(path.finish);
        	if (! unmapped.isEmpty()) {
        		dispatchEvent(new NeighborhoodEvent(NeighborhoodEvent.UNMAPPED, unmapped));
        	}
	    }
	
	    /**
	     * Track the given sprite with the camera.
	     */  
	    public function follow (sprite:PlayerSprite) :void
	    {
	    	stopFollowing();
	    	
	    	// start listening for events from this sprite
	    	sprite.addEventListener(ViewEvent.MOVED, handleSubjectMoved);
	    	_cameraTracking = sprite;
	    	
	    	// immediately move the sprite into view
            scrollViewPointTo(cellCoordinates(sprite.player.position));
	    }
	    
	    /**
	     * Stop tracking whatever sprite we are following.
	     */
	    public function stopFollowing() :void
	    {
	    	if (_cameraTracking != null) {
	    		_cameraTracking.removeEventListener(ViewEvent.MOVED, handleSubjectMoved);
	    		_cameraTracking = null;
	    	}
	    }
	   
	    protected function handleSubjectMoved (event:ViewEvent) :void 
	    {
	    	scrollViewPointTo(Geometry.coordsOf(event.view));
	    }
	        
	    /**
	     * Add a player to the level that this objective is currently associated with, displaying the
	     * player immediately.
	     */ 
        public function addPlayer (player:Player) :PlayerSprite
        {
        	// if we're already displaying the view, just return it
        	const found:PlayerSprite = _playerViews.find(player);
        	if (found != null) {
        		return found;
        	}
        	
        	// construct a new view
        	const sprite:PlayerSprite = new PlayerSprite(this, player);
        	_playerViews.add(player, sprite);
        	
        	// start displaying the view immediately        	
        	addChild(sprite);
        	sprite.moveTo(sprite.positionInCell(this, player.position));
        	return sprite;
        }
	       
	    /**
	     * Remove a player from the level that this objective is currently associate with, making
	     * hiding the player immediately.
	     */
        public function removePlayer (player:Player) :void
        {
        	const sprite:PlayerSprite = _playerViews.take(player);
        	if (sprite != null) {
        		removeChild(sprite);
        	}
        }
        
        public function updateCells (update:CellUpdate) :void
        {
        	Log.debug("updating cell state: "+update);
        	for each (var state:CellState in update.states) {
        		Log.debug("updating state: "+state);
        		state.update(this);
        	}
        }
                
        public function get frameTimer () :FrameTimer
        {
        	return _frameTimer;
        }
        
        public function get startingPosition () :BoardCoordinates
        {
        	return _board.startingPosition;
        }
        
        public function get serverTime () :Number 
        {
        	return _clock.serverTime;
        }
        
        protected var _clock:Chronometer;
        
        protected var _breadcrumbs:BreadcrumbTrail = new BreadcrumbTrail();
        
        protected var _frameTimer:FrameTimer = new FrameTimer();
        
        protected var _cameraTracking:PlayerSprite;
            
        protected var _playerViews:PlayerViews = new PlayerViews();
            	
		protected var _viewFactory:ViewFactory;
		// owner label
		protected var _label:OwnerLabel;
	
		// the viewer
		protected var _viewer:Viewer;
			
		// a representation of the player character 
		protected var _player:Player;
						
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
				
		protected var _board:BoardInteractions;		
		
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