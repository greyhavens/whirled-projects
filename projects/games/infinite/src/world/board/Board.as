package world.board
{
	import arithmetic.BoardCoordinates;
	
	import world.level.Level;
	
	public interface Board extends BoardAccess
	{		
		/**
		 * Get a suggested starting position for a new user entering this board. 
		 */
		function get startingPosition () :BoardCoordinates
		
		function get levelNumber () :int
	}
}