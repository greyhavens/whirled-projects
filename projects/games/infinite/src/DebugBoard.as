package
{
	/**
	 * The board class represents the game board for the current level.  The board is composed of an
	 * infinite grid of cells.  The cells are blank until users populate them with objects.
	 * The board is centered on 0,0.  X coordinates can go arbitrarily positive or negative. 
	 * The ground is positioned at 0Y and the top of the level is a negative number which is 
	 * arbitrary but fixed for the level.  This makes the board parameters count in the same
	 * direction as stage parameters, otherwise things are a nightmare to think about.
	 * 
	 * Positive numbers always return 'ground cells'.  A player may never occupy a ground cell.
	 */
	public class DebugBoard implements Board
	{
		public function DebugBoard (level:Level)
		{
		}

		public function get startingPosition () :BoardCoordinates
		{
			return _startingPosition;	
		}
		
		/**
		 * Return the cell at a given position on the board.
		 */
		public function cellAt (x:int, y:int) :Cell
		{
			//for now, all we want to do is display a 'matrix'
			if (y > 0) {
				return new DebugGroundCell(x, y);
			} else {
				return new DebugCell(x, y);
			}
		}

		protected static const _startingPosition:BoardCoordinates = new BoardCoordinates(0, 0);
	}
}