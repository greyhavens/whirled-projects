package world.arbitration
{
	import arithmetic.BoardCoordinates;	
	import flash.events.IEventDispatcher;
	import world.Cell;
	
	public interface MovableCharacter extends IEventDispatcher
	{
		/**
		 * Return the cell that the player currently occupies if the player is currently in a 
		 * cell, otherwise null.
		 */
		function get cell () :Cell;
	}
}