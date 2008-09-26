package
{
	import flash.events.IEventDispatcher;
	
	import items.ItemPlayer;
	
	/**
	 * This is an item that the player can hold in their inventory.
	 */
	public interface Item extends IEventDispatcher, Viewable
	{
		function addToInventory (inventory:Inventory) :void
		
		function removeFromInventory (inventory:Inventory) :void
		
		function isUsableBy (player:ItemPlayer) :Boolean
		
		function useBy (player:ItemPlayer) :void
	}
}