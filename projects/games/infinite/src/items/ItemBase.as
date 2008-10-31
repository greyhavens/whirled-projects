package items
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class ItemBase extends EventDispatcher implements Item
	{		
		public function ItemBase()
		{
		}
		
		public function addToInventory (inventory:ItemInventory) :void
		{
			inventory.addItem(this);
		}
		
		public function removeFromInventory (inventory:ItemInventory) :void
		{
			inventory.removeItem(this);
		}		
		
		public function isUsableBy (player:ItemPlayer) :Boolean
		{
			Log.debug ("checking to see whether "+this+" can apply to the board - default answer: no");
			return false;
		}
		
		public function useBy (player:ItemPlayer) :void
		{
			Log.debug ("applying "+this+" to board which does nothing");
			// do nothing
		}
		
		public function get code () :int
		{
			throw new Error(this + " doesn't have a code assigned to it");
		}		
	}
}