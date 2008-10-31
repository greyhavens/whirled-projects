package world
{
	import arithmetic.BoardCoordinates;
	import arithmetic.CellIterator;
	import arithmetic.Vector;
	
	import cells.fruitmachine.*;

    import world.board.*;
	
	public class BoxController implements BoardAccess
	{
		public function BoxController(board:BoardAccess)
		{
			_board = board;
			_extent = new SliceMap();
		}
		
		public function cellAt (position:BoardCoordinates) :Cell
		{
			const direction:Vector = _extent.directionFrom(position);
			// we've looked at this cell before, so we return immediately
			if (direction == Vector.IDENTITY) {
//				Log.debug ("cell has been considered for a box before so not considering again");
				return _board.cellAt(position);
			}
			// we've never looked at the row before, so we can't infer a direction in which to scan
			if (direction == null) {
//				Log.debug ("row has never been looked at so we can't infer direction");
				_extent.expandToInclude(position);
				return _board.cellAt(position);
			}
			// we've seen the row before, and we can consider adding a box.
			_extent.expandToInclude(position);
			return simplePossibleBox(position, direction);
		}
		
		public function simplePossibleBox (position:BoardCoordinates, direction:Vector) :Cell
		{
//			Log.debug ("considering adding a box at "+position);
			const current:Cell = _board.cellAt(position);	
			if (! current.canBecomeWindow) {
//				Log.debug ("cell cannot become a window, so abandoning consideration");
				return current;
			}
			if (Math.random() < p) {
				// if the dice throw wins, then we return a Fruit Machine.
//				Log.debug ("returning new machine");  
				return new FruitMachineCell(current.position, FruitMachineCell.ACTIVE, ObjectBox.random());
			}
			
//			Log.debug ("dice rolls failed");
			return current;
		}
		
		public function possibleBox (position:BoardCoordinates, direction:Vector) :Cell
		{
			Log.debug ("considering adding a box at "+position);
			const current:Cell = _board.cellAt(position);	
			if (! current.canBecomeWindow) {
				Log.debug ("cell cannot become a window, so abandoning consideration");
				return current;
			}
			var iterator:CellIterator = current.iterator(_board, direction);
			
			// first check to see that there are no cells in the near vicinity
			var i:int;
			var cell:Cell;
			for (i = 0; i < MIN_DISTANCE; i++) {
				cell = iterator.next();
				Log.debug ("checking "+cell);
				if (cell is FruitMachineCell) {
					return current;
				}
			}
			
			// next, increase the likelyhood of placing a box as we move outside the MIN_DISTANCE;
			while (i < MAX_DISTANCE) {
				i++;
				cell = iterator.next();				
				Log.debug ("checking "+cell);
				
				// stop if we find a cell near enough
				if (cell is FruitMachineCell) {
					return current;
				}
				
				Log.debug ("rolling dice p="+p);
				// we roll the dice once for each cell additionally that we have to count
				if (Math.random() < p) {
					// if the dice throw wins, then we return a Fruit Machine.
					Log.debug ("returning new machine");  
					return new FruitMachineCell(cell.position, FruitMachineCell.ACTIVE, ObjectBox.random());
				}
			}
			Log.debug ("dice rolls all failed");
			return current;
		}
		
		protected var _board:BoardAccess;
		protected var _extent:SliceMap;
		
		protected const p:Number = (0.5 / (MAX_DISTANCE - MIN_DISTANCE));
		protected const MIN_DISTANCE:int = 10;
		protected const MAX_DISTANCE:int = 20; 
	}
}