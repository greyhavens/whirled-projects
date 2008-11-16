package client
{
	import arithmetic.*;
	
	import world.Cell;
	import world.board.*;
	
	public class CellScrollBuffer implements BoardAccess
	{
		public function CellScrollBuffer(objective:Objective, board:BoardInteractions)
		{
			_objective = objective;
			_board = board;
		}

		public function get origin () :BoardCoordinates
		{
			return _boardOrigin;
		}

		/**
		 * Buffer a region of the board.  An cells already in the buffer are cleared without
		 * notice.
		 */
		public function initializeWith (rect:BoardRectangle) :void
		{
			// we store the board origin when the buffer position is set initially but don't
			// shift it as we shift around the space.
			_boardOrigin = rect.origin;			
			_extent = rect;
			_cells = new Array();			
			fillBuffer(rect);			
		}
		
		public function fillBuffer (rect:BoardRectangle) :void
		{
			var x:int, y:int;
			var c:Cell;
			for (x = 0; x <= rect.width; x ++) {
				_cells.push(new Array);
				for (y = 0; y <= rect.height; y++ ) {
					c = _board.cellAt(new BoardCoordinates(x + rect.x, y + rect.y));
					_cells[x][y] = c;
					c.addToObjective(_objective);
				}
			}
		}
		
		public function flushBuffer () :void
		{
			var x:int, y:int;
			for (x = 0; x < _cells.length; x++ ) {
				for (y = 0; y < (_cells[x] as Array).length; y++ ) {					
					(_cells[x][y] as Cell).removeFromObjective();
			 	}
			}
			_cells = new Array();
		}
		
		/**
		 * Move the buffer
		 */
		public function shiftBufferTo (rect:BoardRectangle) :void
		{
			// if we're already in position do nothing			
			if (rect.equals(_extent)) {
				return;
			}

			// if the new rectangle doesn't overlap the old one
			// then just throw it all away and start again
			if (! rect.overlaps(_extent)) {
				flushBuffer();
				fillBuffer(rect);
				Log.debug ("buffed doesn't overlap, so flushing complete buffer");
				_extent = _extent.translatedBy(rect.offsetFrom(_extent));
				return;
			}
		
			const offset:Vector = rect.offsetFrom(_extent);			
			//Log.debug ("shifting buffer by: "+offset);
			
			removeColumns(offset.dx);
			removeRows(offset.dy);
			populateRows(offset);
			populateColumns(offset);
			
			_extent = _extent.translatedBy(offset);
		}
		
		/**
		 * Add cells to the rows up to the current width ( 
		 */
		protected function populateRows (offset:Vector) :void
		{			
			var i:int;
			var xStart:int, xFinish:int;
				
			if (offset.dy > 0) {
				// we're going down
				xStart = _extent.x + offset.dx;
				xFinish = xStart + _cells.length;
												
				for (i = 1; i <= offset.dy; i++) {
					addRowBottom(xStart, xFinish, i + _extent.bottom);
				}
				return;
			}
			
			if (offset.dy < 0) {
				// we're going up
				xStart = _extent.x + offset.dx;
				xFinish = xStart + _cells.length;
				
				for (i = -1; i >= offset.dy; i--) {
					addRowTop(xStart, xFinish, _extent.y + i);
				}
				return;
			}
			
			// Log.debug ("added no rows");
		}
		
		/**
		 * Add cells to the sides of the buffer if needed
		 */
		protected function populateColumns (offset:Vector) :void
		{
			var i:int;
			var yStart:int, yFinish:int;
			
			if (offset.dx > 0) {
				// populate rows on the right
				yStart = _extent.y + offset.dy;
				yFinish = yStart + _extent.height + 1;
				
				// Log.debug ("adding columns to the right: "+offset.dx);
				
				for (i = 1; i <= offset.dx; i++) {
					addColumnRight(_extent.right + i, yStart, yFinish);
				}				
				return;
			}
			
			if (offset.dx < 0 ) {
				// populate rows on the left
				yStart = _extent.y + offset.dy;
				yFinish = yStart + _extent.height + 1;
				
				for (i = -1; i >= offset.dx; i--) {
					addColumnLeft(_extent.x + i, yStart, yFinish);
				}
				return;		
			}
			
			// Log.debug ("added no columns");
		}
		
		protected function addRowTop (xStart:int, xFinish:int, row:int) :void
		{
			// Log.debug ("adding row to the top at: "+row+" from: "+xStart+" to: "+xFinish);			
			var x:int, c:Cell;
			for (x = xStart; x < xFinish; x++) {
				c = memoryOrBoard(new BoardCoordinates(x, row));
				c.addToObjective(_objective);
				(_cells[x - xStart] as Array).unshift(c);
			}
		}
		
		protected function addRowBottom (xStart:int, xFinish:int, row:int) :void
		{
			// Log.debug ("adding row to the bottom at: "+row+" from: "+xStart+" to: "+xFinish);
			var x:int, c:Cell;
			for (x = xStart; x < xFinish; x++) {
				c = memoryOrBoard(new BoardCoordinates(x, row));
				c.addToObjective(_objective);
				(_cells[x - xStart] as Array).push(c);
			}
		}

		protected function addColumnRight(column :int, yStart :int, yFinish :int) :void
		{
			// Log.debug ("adding column to the right at: "+column+" from: "+yStart+" to: "+yFinish);
			_cells.push(createColumn(column, yStart, yFinish));
		}
		
		protected function addColumnLeft(column:int, yStart:int, yFinish:int) :void
		{
			// Log.debug ("adding column to the left at: "+column+" from: "+yStart+" to: "+yFinish);
			_cells.unshift(createColumn(column, yStart, yFinish));
		}
				
		/**
		 * Create a new array containing a row of cells with a given start position and end position from
		 * a specific row within the board.
		 */
		protected function createColumn (column:int, yStart:int, yFinish:int) :Array
		{
			const array:Array = new Array();
			var y:int, c:Cell;
			for (y = yStart; y < yFinish; y++) {
				c = memoryOrBoard(new BoardCoordinates(column, y));
				c.addToObjective(_objective);
				array.push(c);
			}
			return array;
		}
		
		/**
		 * Remove rows from the array, notifying the cells of their removal.
		 * 
		 * Old rows will be
		 * removed, and the cells notified of their removal.
		 */
		protected function removeRows (offset:int) :void
		{			
			var i:int;

			if (offset > 0) {
				removeTop(Math.abs(offset));
				return;
			}
			
			if (offset < 0) {
				removeBottom(Math.abs(offset));
				return;
			}
			
			// Log.debug ("not removing any rows");
		}

		/**
		 * Remove columns from the array, notifying the cells of their removal.
		 * 
		 */
		protected function removeColumns (offset:int) :void
		{
			var i:int, y:int;
			if (offset > 0) {
				removeLeft(Math.abs(offset));
				return;
			}
			
			if (offset < 0) {				
				removeRight(Math.abs(offset));
				return;
			}
			
			// Log.debug ("not removing any columns");
		}
		
		protected function removeTop (count :int) :void
		{
			// Log.debug ("removing "+count+" rows from the top");
			var i:int, j:int;
			for (i = 0; i < count; i++) {
				for (j = 0; j < _cells.length; j++) {
					((_cells[j] as Array).shift() as Cell).removeFromObjective();
				}
			}			
		}
		
		protected function removeBottom (count:int) :void
		{
			// Log.debug ("removing "+count+" rows from the bottom");			
			var i:int, j:int;
			for (i = 0; i < count; i++) {
				for (j = 0; j < _cells.length; j++) {
					((_cells[j] as Array).pop() as Cell).removeFromObjective();
				}
			}
		}
		
		/**
		 * Remove the elements from the left of the buffer from the objective
		 */
		protected function removeLeft (count:int) :void
		{
			// Log.debug ("removing "+count+" rows from the left");
			var i:int;
			for (i = 0; i < count; i++) {
				removeFromObjective(_cells.shift());
			}
		}
		
		/**
		 * Remove the elements at the right of the buffer from the objective
		 */
		protected function removeRight (count:int) :void
		{
			// Log.debug ("removing "+count+" rows from the right");
			var i:int;
			for (i = 0; i < count; i++) {
				removeFromObjective(_cells.pop());
			}			
		}

		/**
		 * Remove all of the elements in an array from the objective.
		 */
		protected function removeFromObjective (row:Array) :void
		{
			var i:int;
			for (i = 0; i < row.length; i++) {				
				(row[i] as Cell).removeFromObjective();
			}
		}

		/**
		 * Return a cell from the buffer if present, otherwise return it from the board.
		 */
		public function cellAt (position:BoardCoordinates) :Cell 
		{
			if (_extent.contains(position)) { 
				const v:Vector = _extent.relativePosition(position);
				return _cells[v.dx][v.dy] as Cell;		
			}
			return _board.cellAt(position);
		}
		
		public function replace (cell:Cell) :void
		{
			if (_extent.contains(cell.position)) {
				//Log.debug("replacing cell in view");
				const v:Vector = _extent.relativePosition(cell.position);
				const old:Cell = _cells[v.dx][v.dy] as Cell;
				old.removeFromObjective();
				_cells[v.dx][v.dy] = cell;
				cell.addToObjective(_objective);
			}
			_board.replace(cell);
		}

		public function memoryOrBoard (position:BoardCoordinates) :Cell 
		{
			const found:Cell = _objective.cellAt(position);
			if (found != null) {
				// Log.debug ("recalled "+found);
				return found;
			}
			return _board.cellAt(position);
		}

		// the actual array of cells - Note: the Columns are the sub arrays.
		protected var _cells:Array;
		
		// the buffer mediates between the objective and the board
		protected var _objective:Objective;
		protected var _board:BoardInteractions;

		// the position and extent of the buffer
		protected var _extent:BoardRectangle = new VoidBoardRectangle();
		protected var _boardOrigin:BoardCoordinates;
	}
}