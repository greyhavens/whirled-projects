package cells
{
	import server.Messages.CellState;
	
	/**
	 * Interface defining the relationship between a cell and the persistent world.
	 */
	public interface CellWorld
	{
		/**
		 * Distribute a cell state change to anyone who needs to know about it.
		 */ 
		function distributeState (state:CellState) :void
	}
}