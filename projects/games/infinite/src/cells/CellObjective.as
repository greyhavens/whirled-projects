package cells
{
	import arithmetic.VoidBoardRectangle;
    import world.Cell;
	
	public interface CellObjective
	{
		/**
		 * Show the cell on the objective.  Once the cell is shown, it may be interacted with.
		 */
		function showCell (c:Cell) :void 
		
		/**
		 * Hide the cell from the objective.  Once hidden, interaction is no longer possible.
		 */
		function hideCell (c:Cell) :void
				
		/**
		 * Display ownership information about the cell to the user.
		 */
		function displayOwnership (cell:Cell) :void
		
		/**
		 * Stop displaying ownership information about the cell to the user.
		 */
		function hideOwnership (cell:Cell) :void				
	}
}