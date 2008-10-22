package world.board
{
	import arithmetic.BoardCoordinates;
	
	public interface Board extends BoardAccess
	{		
		/**
		 * Get a suggested starting position for a new user entering this board. 
		 */
		function get startingPosition () :BoardCoordinates
	}
}