package world.board
{
	import arithmetic.BoardCoordinates;
    import world.Cell;
	
	public interface BoardInteractions extends BoardAccess
	{
		/**
		 * Replace a board cell with a new one positioned at the same position.
		 */
		function replace (newCell:Cell) :void
	}
}