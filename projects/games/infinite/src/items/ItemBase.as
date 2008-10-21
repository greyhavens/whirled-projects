package items
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import sprites.ItemSprite;

	public class ItemBase extends EventDispatcher implements Item
	{		
		public function ItemBase(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		protected function registerEventHandlers (source:EventDispatcher) :void
		{
			source.addEventListener(MouseEvent.MOUSE_DOWN, handleCellClicked);			
		}

		protected function handleCellClicked (event:MouseEvent) :void
		{
			dispatchEvent(new ItemEvent(ItemEvent.ITEM_CLICKED, this));			
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
			trace ("checking to see whether "+this+" can apply to the board - default answer: no");
			return false;
		}
		
		public function useBy (player:ItemPlayer) :void
		{
			trace ("applying "+this+" to board which does nothing");
			// do nothing
		}
		
		public function get code () :int
		{
			throw new Error(this + " doesn't have a code assigned to it");
		}		
	}
}