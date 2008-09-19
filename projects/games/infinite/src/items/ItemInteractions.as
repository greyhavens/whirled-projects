package items
{
	/**
	 * Various ways items can interact with players.  Implemented by players or their proxies.
	 */
	public interface ItemInteractions extends BoardAccess, BoardInteractions
	{
		/**
		 * Return the player's current cell.
		 */
		function get cell () :Cell;
		
		/**
		 * Cause the player to teleport.
		 */
		function teleport () :void;
	}
}