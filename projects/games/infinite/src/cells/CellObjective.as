package cells
{
	import flash.events.MouseEvent;
	
	import sprites.CellSprite;
	
	import world.Cell;
	import world.Chronometer;
	
	public interface CellObjective extends Chronometer
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
		
		/**
		 * Check to see whether the player can move to this cell, and indicate that fact using 'footprints'
		 * on the display.
		 */
		function checkFootprints (sprite:CellSprite) :void
		
		/**
		 * Indicate that the mouse has moved off the given sprite.
		 */		
		function moveOutSprite(sprite:CellSprite) :void;				
	}
}