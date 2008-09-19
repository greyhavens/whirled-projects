package
{
	import arithmetic.BoardCoordinates;
	
	/**
	 * Provide basic access to the board
	 */
	public interface BoardAccess
	{
		function cellAt (position:BoardCoordinates) :Cell
	}
}