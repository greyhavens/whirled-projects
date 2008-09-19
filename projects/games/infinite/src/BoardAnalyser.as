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
		public function hasSidewaysPath (origin:Cell, destination:Cell) :Boolean
		{
			const start:BoardCoordinates = origin.position;
			const finish:BoardCoordinates = destination.position;
			
			// for now, there is no path between two positions that are not on the same level.
			if (start.y != finish.y) {
				return false;
			}
			
			var x:int;
			
			// is the proposed movement to the left?			
			if (start.x < finish.x) {
				trace("looking right");
				for (x = start.x + 1; x <= finish.x; x++)
				{
					if (! _board.cellAt(new BoardCoordinates(x, start.y)).climbRightTo ) {
						return false;
					}					
				}
				return true;
			}
			
			if (start.x > finish.x) {
				trace("looking left from: "+start.x+" to: "+finish.x);
				for (x = start.x - 1; x >= finish.x; x--) {
					trace ("checking "+x+", "+start.y);
					if (! _board.cellAt(new BoardCoordinates(x, start.y)).climbLeftTo ) {
						trace ("cannot move left to: "+x+", "+start.y+" climbLefto="+_board.cellAt(new BoardCoordinates(x, start.y)).climbLeftTo);
						return false;
					}
				}
				return true;
			}
			
			// you can't move to a position that you already occupy			
			return false;	
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