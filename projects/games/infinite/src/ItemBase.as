package
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import items.ItemPlayer;
	
	import sprites.ItemSprite;

	public class ItemBase extends EventDispatcher implements Item
	{		
		public function ItemBase(target:IEventDispatcher=null)
		{
			super(target);
		}
	
		public function get view () :DisplayObject {
			return new ItemSprite(errorItem);
		}
		
		protected function registerEventHandlers (source:EventDispatcher) :void
		{
			source.addEventListener(MouseEvent.MOUSE_DOWN, handleCellClicked);			
		}

		protected function handleCellClicked (event:MouseEvent) :void
		{
			dispatchEvent(new ItemEvent(ItemEvent.ITEM_CLICKED, this));			
		}
	
		public function addToInventory (inventory:Inventory) :void
		{
			inventory.addItem(this);
		}
		
		public function removeFromInventory (inventory:Inventory) :void
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
		
		[Embed(source="../rsrc/png/error-item.png")]
		public static const errorItem:Class;
	}
}