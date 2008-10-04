package paths
{
	import arithmetic.BoardCoordinates;
	
	public interface PathFollower
	{
		/**
		 * Follow the supplied path.
		 */
		function follow (path:Path) :void;		

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