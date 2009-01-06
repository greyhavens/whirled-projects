package world.board
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.IEventDispatcher;
	
	public interface Board extends BoardAccess, IEventDispatcher
	{		
		/**
		 * Get a suggested starting position for a new user entering this board. 
		 */
		function get startingPosition () :BoardCoordinates
		
		function get levelNumber () :int
	}
}