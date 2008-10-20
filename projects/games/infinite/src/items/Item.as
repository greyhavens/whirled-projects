package items
{
	import flash.events.IEventDispatcher;
	
	import items.ItemInventory;
	import items.ItemPlayer;
	
	/**
	 * This is an item that the player can hold in their inventory.
	 */
	public interface Item extends IEventDispatcher
	{
		function addToInventory (inventory:ItemInventory) :void
		
		function removeFromInventory (inventory:ItemInventory) :void
		
		function isUsableBy (player:ItemPlayer) :Boolean
		
		function useBy (player:ItemPlayer) :void
	}
}