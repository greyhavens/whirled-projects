package cells
{
	import items.Item;
	
	/**
	 * Various different ways a cell can interact with a player.  Implemented by players or their
	 * proxies.
	 */
	public interface CellInteractions
	{		
		/**
		 * Called when the user receives an item.
		 */
		function receiveItem (item:Item) :void
		
		/**
		 * Return true if the user can receive an item.
		 */
		function canReceiveItem () :Boolean		
	}
}