package world.board
{
	import world.Cell;
	
	public interface BoardInteractions extends Board
	{
		/**
		 * Replace a board cell with a new one positioned at the same position.
		 */
		function replace (newCell:Cell) :void
	}
}