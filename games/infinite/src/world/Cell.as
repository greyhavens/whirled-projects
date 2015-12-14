package world
{
	import arithmetic.BoardCoordinates;
	import arithmetic.CellIterator;
	import arithmetic.Vector;
	
	import cells.CellAffordances;
	import cells.CellObjective;
	
	import flash.events.IEventDispatcher;
	
	import server.Messages.CellState;
	
	import world.board.*;
	import world.level.Level;
		
	/**
	 * Interface providing the details of a cell within the game board.
	 */
	public interface Cell extends CellAffordances, PlayerInteractions, IEventDispatcher
	{		
		/**
		 * Return the position on the board of this cell
		 */
		function get position () :BoardCoordinates;
		

		/**
		 * Called to cause the cell to add itself to the objective.
		 */
		 function addToObjective(objective:CellObjective) :void		

		/**
		 * Called to cause the cell to remove itself from the objective.  Will do
		 * nothing of the cell is already removed.
		 */
		function removeFromObjective() :void		

		/**
		 * Called to cause the cell to be added to a level.
		 */
		function addToLevel (level:Level) :void		

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
		
		/**
		 * Return true if this cell is on the same row as another.
		 */
		function sameRowAs (other:Cell) :Boolean		 
		 
		/**
		 * Return the code for a given cell.
		 */
		function get code () :int
		
		/**
		 * Return the name of the object as a string.
		 */
		function get objectName () :String
		
		/**
		 * Return the owner of an object.
		 */
		function get owner () :Owner

        /**
         * Return a snapshot of this cell's state.
         */ 
        function get state () :CellState
        
        /**
         * Update the state of a given cell.
         */ 
        function updateState (owners:Owners, clock:Chronometer, board:BoardInteractions, state:CellState) :void
        
        /**
         * Cause this cell to distribute its state to all interested parties.
         */
        function distributeState () :void;        
	}
}