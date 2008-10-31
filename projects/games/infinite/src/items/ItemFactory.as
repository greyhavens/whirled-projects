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

        public function makeItem (object:Object) :Item
        {
        	switch (object.code) {
        		case ItemCodes.LADDER: return new Ladder(object);
        		case ItemCodes.OIL_CAN: return new OilCan();
        		case ItemCodes.SPRING: return new Spring();
        		case ItemCodes.TELEPORTER: return new Teleporter();
        	}
        	throw new Error(this + " doesn't know how to make an item of type "+object.code);
        }
	}
}