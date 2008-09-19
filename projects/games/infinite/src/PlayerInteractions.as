package
{
	import cells.CellInteractions;
	
	/**
	 * Various different ways a player can interact with a cell. (Implemented by Cells or their
	 * proxies)
	 */
	public interface PlayerInteractions
	{
		/**
		 * A player has completed a transition into the cell and is now stationary and 'in' the cell.
		 */
		function playerHasArrived (player:CellInteractions) :void

		/**
		 * A player who was present in the cell begins to depart.
		 */		
		function playerBeginsToDepart () :void
	}
}