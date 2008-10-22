package
{
	import arithmetic.BoardCoordinates;
    import world.Cell;
	
	public interface BoardInteractions extends BoardAccess
	{
		/**
		 * Replace a board cell at the given position
		 */
		function replace (position:BoardCoordinates, newCell:Cell) :void
	}
}