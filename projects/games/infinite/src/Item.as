package
{
	import flash.events.IEventDispatcher;
	
	import items.ItemInteractions;
	
	/**
	 * This is an item that the player can hold in their inventory.
	 */
	public interface Item extends IEventDispatcher, Viewable
	{
		function addToInventory (inventory:Inventory) :void
		
		function removeFromInventory (inventory:Inventory) :void
		
		function isUsableBy (player:ItemInteractions) :Boolean
		
		function useBy (player:ItemInteractions) :void
	}
}