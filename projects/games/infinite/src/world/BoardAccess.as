package world
{
	import arithmetic.BoardCoordinates;
	import world.Cell;
	
	/**
	 * Provide basic access to the board
	 */
	public interface BoardAccess
	{
		function cellAt (position:BoardCoordinates) :Cell
	}
}
