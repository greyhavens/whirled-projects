package paths
{
	import arithmetic.BoardCoordinates;
	
	public interface PathFollower
	{
		/**
		 * Move sideways to the given cell.
		 */
		function moveSideways (newCell:BoardCoordinates) :void

		/**
		 * Climb up or down to the given cell.
		 */
		function climb (newCell:BoardCoordinates) :void
	}
}