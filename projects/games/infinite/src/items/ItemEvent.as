package items
{
	import flash.events.Event;

	public class ItemEvent extends Event
	{
		public static const ITEM_CLICKED:String = "item_clicked";

		public var item:Item;
		
		public function ItemEvent(type:String, item:Item)
		{
			super(type);
			this.item = item;
		}
	}
}