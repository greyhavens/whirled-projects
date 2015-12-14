package items
{
	import items.ladder.LadderView;
	import items.oilcan.OilcanView;
	import items.spring.SpringView;
	import items.teleporter.TeleporterView;
	
	import sprites.ItemSprite;
	
	public class ItemViewFactory
	{
		public function ItemViewFactory()
		{
		}

        public function viewOf (item:Item) :ItemSprite
        {
        	switch (item.code) {
        		case ItemCodes.OIL_CAN: return new OilcanView(item);
                case ItemCodes.SPRING: return new SpringView(item);
                case ItemCodes.TELEPORTER: return new TeleporterView(item);
                case ItemCodes.LADDER: return new LadderView(item);
        	}
        	throw new Error("ItemViewFactory doesn't know how to construct a view for "+item);
        }
	}
}
