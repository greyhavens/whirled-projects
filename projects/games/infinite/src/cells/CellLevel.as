package cells
{
	import world.Cell;
	
	/**
	 * Interface defining the relationship between a cell and the level it's part of.
	 */
	public interface CellLevel
	{
		/**
		 * Distribute a cell state change to anyone who needs to know about it.
		 */ 
		function distributeState (cell:Cell) :void
	}
}