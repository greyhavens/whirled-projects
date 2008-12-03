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
			
	}
}