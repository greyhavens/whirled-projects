package
{
	import arithmetic.BoardCoordinates;
	import arithmetic.CellIterator;
	import arithmetic.Vector;
	
	import flash.events.IEventDispatcher;
		
	/**
	 * Interface providing the details of a cell within the game board.
	 */
	public interface Cell extends IEventDispatcher, Viewable, CellAffordances, PlayerInteractions
	{		
		/**
		 * Return the position on the board of this cell
		 */
		function get position () :BoardCoordinates;
		

		/**
		 * Called to cause the cell to add itself to the objective.
		 */
		 function addToObjective(objective:Objective) :void		

		/**
		 * Called to cause the cell to remove itself from the objective.  Will do
		 * nothing of the cell is already removed.
		 */
		function removeFromObjective() :void		

		/**
		 * Return an iterator for iterating though cells on the supplied board in the specified
		 * direction.  The iterator will not include the current cell as a result.
		 */
		function iterator (board:BoardAccess, direction:Vector) :CellIterator

		/**
		 * Return true if this cell is part of the same object as another cell.
		 */
		function adjacentPartOf (other:Cell) :Boolean
		
		/**
		 * Return true if the cell is above ground level.
		 */
		function isAboveGroundLevel () :Boolean		
	}
}