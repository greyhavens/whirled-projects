package items
{
    import world.Cell;
    import world.BoardAccess;
    import world.BoardInteractions;
    
	/**
	 * Defines the features of a player that items interact with.
	 */
	public interface ItemPlayer extends BoardAccess, BoardInteractions, Owner
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