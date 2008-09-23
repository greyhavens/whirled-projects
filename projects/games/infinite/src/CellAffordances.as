package
{
	import arithmetic.Vector;
	
	/**
	 * Affordances offered to the player by cells.
	 */
	public interface CellAffordances
	{
		/**
		 * True if it's possible to climb up into this cell.
		 */
		function get climbUpTo () :Boolean
				
		/**
		 * True if it's possible to climb down into this cell.
		 */
		function get climbDownTo () :Boolean
		
		/**
		 * True if it's possible to climb left into this cell.
		 */
		function get climbLeftTo () :Boolean
		
		/**
		 * True if it's possible to climb right into this cell.
		 */
		function get climbRightTo () :Boolean
		
		/**
		 * True if it's possible to enter the cell using the specified vector.
		 */
		function canEnterBy (direction:Vector) :Boolean
		
		/**
		 * True if it's possible to grip this cell.
		 */
		function get grip () :Boolean
		
		/**
		 * True if it's possible to leave this cell.
		 */
		function get leave () :Boolean
		
		/**
		 * True if this cell can be replaced by another one.
		 */ 
		function get replacable () :Boolean
		
		/**
		 * True if this cell can be changed into a window.
		 */
		function get canBecomeWindow () :Boolean		
	}
}