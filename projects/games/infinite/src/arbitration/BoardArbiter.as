package arbitration
{
	import arithmetic.*;
	
	import paths.ClimbingPath;
	import paths.Path;
	import paths.PathEvent;
	import paths.SidewaysPath;
	
	public class BoardArbiter implements MoveArbiter
	{
		public function BoardArbiter(board:BoardAccess)
		{
			_board = board;
		}
	
		public function proposeMove (player:MovableCharacter, destination:Cell) :void 
		{
			var path:Path;		
			path = sidewaysPath(player, destination);
			
			if (path == null)
			{
				path = climbingPath(player, destination);
			}
			
			if (path != null) {
				dispatchStart(player, path);
			}
		}
		
		/**
		 * Determine whether there is a clear path between two different positions on the board.
		 */
		public function sidewaysPath (player:MovableCharacter, destination:Cell) :Path
		{			
			// for now, there is no path between two positions that are not on the same level.
			if (! player.cell.sameRowAs(destination)) {				
				return null;
			}

			trace ("analysing sideways path from "+player.cell+" to "+destination);
			var path:CellPath = new CellPath(_board, player.cell, destination);
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
					return new SidewaysPath(player.cell.position, found.position);
				}
			}			
			
			// each cell in the path could be entered and was grippable.
			// so we return the whole path.			
			return new SidewaysPath(player.cell.position, destination.position);
		}
		
		protected function dispatchStart(player:MovableCharacter, path:Path) :void
		{
			player.dispatchEvent(new PathEvent(PathEvent.PATH_START, path));
		}
		
		public function climbingPath (player:MovableCharacter, destination:Cell) :Path
		{
			const start:BoardCoordinates = player.cell.position;
			const finish:BoardCoordinates = destination.position;
			
			trace("checking for climbing path...");
			
			// there is no way to climb horizontally.
			if (start.x != finish.x) {
				return null;				
			}
						
			var y:int;
			
			// is the proposed climb upwards?
			if (start.y < finish.y) {
				trace("looking downwards");
				for (y = start.y + 1; y <= finish.y; y++) {
					if (! _board.cellAt(new BoardCoordinates(start.x, y)).climbDownTo ) {
						return null;
					}
				}
				return new ClimbingPath(player.cell.position, destination.position);
			}
			
			// is the proposed climb downwards?
			if (start.y > finish.y) {
				trace("looking upwards");
				for (y = start.y - 1; y >= finish.y; y--) {
					if (! _board.cellAt(new BoardCoordinates(start.x, y)).climbUpTo ) {
						trace ("cannot climb up to cell at: "+start.x+", "+y);
						return null;
					}
				}
				// the player can climb up
				return new ClimbingPath(player.cell.position, destination.position);
			}
			
			// the selected cell is neither above nor below.
			return null;
		}		
		
		protected var _board:BoardAccess;
	}
}