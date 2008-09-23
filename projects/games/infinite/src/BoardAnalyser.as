package
{
	import arithmetic.*;
	
	public class BoardAnalyser
	{
		public function BoardAnalyser(board:BoardAccess)
		{
			_board = board;
		}
	
		/**
		 * Determine whether there is a clear path between two different positions on the board.
		 */
		public function sidewaysPath (origin:Cell, destination:Cell) :Path
		{			
			// for now, there is no path between two positions that are not on the same level.
			if (! origin.sameRowAs(destination)) {				
				return null;
			}

			trace ("analysing sideways path from "+origin+" to "+destination);
			var path:CellPath = new CellPath(_board, origin, destination);
			path.next(); // discard the start position since that's where the user already is.
			while (path.hasNext()) {
				var found:Cell = path.next();
				
				// if the cell cannot be entered from the direction of the path, then we return
				// no path.
				if (!found.canEnterBy(path.delta())) {
					return null;
				}

				// if the user is asking to traverse a cell that's not grippable - make them
				// land there so that they fall. 
				if (!found.grip) {
					return new Path(origin, found);
				}
			}			
			
			// each cell in the path could be entered and was grippable.
			// so we return the whole path.
			return new Path(origin, destination);
		}
		
		public function hasClimbingPath (origin:Cell, destination:Cell):Boolean
		{
			const start:BoardCoordinates = origin.position;
			const finish:BoardCoordinates = destination.position;
			
			trace("checking for climbing path...");
			
			// there is no way to climb horizontally.
			if (start.x != finish.x) {
				return false;				
			}
						
			var y:int;
			
			// is the proposed climb upwards?
			if (start.y < finish.y) {
				trace("looking downwards");
				for (y = start.y + 1; y <= finish.y; y++) {
					if (! _board.cellAt(new BoardCoordinates(start.x, y)).climbDownTo ) {
						return false;
					}
				}
				return true;
			}
			
			// is the proposed climb downwards?
			if (start.y > finish.y) {
				trace("looking upwards");
				for (y = start.y - 1; y >= finish.y; y--) {
					if (! _board.cellAt(new BoardCoordinates(start.x, y)).climbUpTo ) {
						trace ("cannot climb up to cell at: "+start.x+", "+y);
						return false;
					}
				}
				// the player can climb up
				return true;
			}
			
			// the selected cell is neither above nor below.
			return false;
		}		
		
		protected var _board:BoardAccess;
	}
}