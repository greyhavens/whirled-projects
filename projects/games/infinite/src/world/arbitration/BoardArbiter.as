package world.arbitration
{
	import arithmetic.*;
	
	import paths.Path;
	
	import world.Cell;
	import world.CellPath;
	import world.board.*;
	
	public class BoardArbiter implements MoveArbiter
	{
		public function BoardArbiter(board:BoardAccess)
		{
			_board = board;
		}
	
		public function proposeMove (player:MovablePlayer, destination:Cell) :void 
		{
			if (player.isMoving()) {
				Log.debug (this+" ignoring proposed move to "+destination+" because "+player+
				    " is already moving");
				return;
			}
			
			if (!player.cell.leave) {
				Log.debug (this+" ignoring proposed move to "+destination+" because cell will not allow the player to leave");
				return;
			}
			
			var path:Path = findPath(player, destination);
			if (path != null) {
				dispatchStart(player, path);
			}
		}
		
		/**
		 * Find a path between the player's location and the given destination.  Return null if no path can be found, otherwise
		 * return the path.
		 */
		public function findPath (player:MovablePlayer, destination:Cell) :Path
		{
            var path:Path;      
            path = sidewaysPath(player, destination);
            
            if (path == null)
            {
                path = climbingPath(player, destination);
            }

            return path;			
		}
		
		/**
		 * Determine whether there is a clear path between two different positions on the board.
		 */
		public function sidewaysPath (player:MovablePlayer, destination:Cell) :Path
		{			
			// for now, there is no path between two positions that are not on the same level.
			if (! player.cell.sameRowAs(destination)) {				
				return null;
			}

			//Log.debug ("analysing sideways path from "+player.cell+" to "+destination);
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
					return Path.sideways(player.cell.position, found.position);
				}
			}			
			
			// each cell in the path could be entered and was grippable.
			// so we return the whole path.			
			return Path.sideways(player.cell.position, destination.position);
		}
		
		protected function dispatchStart(player:MovablePlayer, path:Path) :void
		{
			Log.debug("dispatching "+path+" to "+player);
			player.dispatchEvent(new MoveEvent(MoveEvent.PATH_START, player, path));
		}
		
		public function climbingPath (player:MovablePlayer, destination:Cell) :Path
		{
			const start:BoardCoordinates = player.cell.position;
			const finish:BoardCoordinates = destination.position;
			
			//Log.debug("checking for climbing path...");
			
			// there is no way to climb horizontally.
			if (start.x != finish.x) {
				return null;				
			}
						
			var y:int;
			
			// is the proposed climb upwards?
			if (start.y < finish.y) {
				//Log.debug("looking downwards");
				for (y = start.y + 1; y <= finish.y; y++) {
					if (! _board.cellAt(new BoardCoordinates(start.x, y)).climbDownTo ) {
						return null;
					}
				}
				return Path.climb(player.cell.position, destination.position);
			}
			
			// is the proposed climb downwards?
			if (start.y > finish.y) {
				//Log.debug("looking upwards");
				for (y = start.y - 1; y >= finish.y; y--) {
					if (! _board.cellAt(new BoardCoordinates(start.x, y)).climbUpTo ) {
						Log.debug ("cannot climb up to cell at: "+start.x+", "+y);
						return null;
					}
				}
				// the player can climb up
				return Path.climb(player.cell.position, destination.position);
			}
			
			// the selected cell is neither above nor below.
			return null;
		}
		
		public function toString () :String
		{
			return "board arbiter";
		} 
		
		protected var _board:BoardAccess;
	}
}