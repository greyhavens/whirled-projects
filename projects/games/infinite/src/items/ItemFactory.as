package items
{
	import items.ladder.Ladder;
	import items.oilcan.OilCan;
	import items.spring.Spring;
	import items.teleporter.Teleporter;
	
	public class ItemFactory
	{
		public function ItemFactory()
		{
		}

        public function makeItem (attributes:Object) :Item
        {
        	switch (attributes.code) {
        		case ItemCodes.LADDER: return new Ladder(attributes);
        		case ItemCodes.OIL_CAN: return new OilCan();
        		case ItemCodes.SPRING: return new Spring();
        		case ItemCodes.TELEPORTER: return new Teleporter();
        	}
        	throw new Error(this + " doesn't know how to make an item of type "+attributes.code);
        }
	}
}