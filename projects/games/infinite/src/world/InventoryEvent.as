package world
{
	import flash.events.Event;
	
	import items.Item;

	public class InventoryEvent extends Event
	{
		public var item:Item;
		public var player:Player;
		public var position:int;
		
		public function InventoryEvent(type:String, player:Player, item:Item, position:int)
		{
			super(type);
			this.item = item;
			this.player = player;			
			this.position = position;
		}
		
		override public function clone():Event
		{
			return new InventoryEvent(type, player, item, position);
		}

		public static const RECEIVED:String = "item_received";			
	}
}