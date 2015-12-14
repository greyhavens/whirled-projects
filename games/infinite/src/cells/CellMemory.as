package cells
{
	import arithmetic.BoardCoordinates;
    import world.Cell;
	
	public interface CellMemory
	{
		/**
		 * Remember the supplied cell in the memory.
		 */
		function remember (cell:Cell) :void

		/**
		 * Recall the cell associated with the supplied position from the memory.
		 */
		function recall (position:BoardCoordinates) :Cell
			
		/**
		 * Forget the supplied cell.
		 */	
		function forget (cell:Cell) :void
	}
}