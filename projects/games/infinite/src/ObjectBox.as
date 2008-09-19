package
{
	import cells.CellInteractions;
	
	import items.Ladder;
	import items.OilCan;
	import items.Spring;
	import items.Teleporter;
	
	/**
	 * A box containing a set of objects, one of which could be given out to the user.
	 */
	public class ObjectBox
	{		
		public function ObjectBox(item:Item)
		{
			_item = item;
		}
		
		/**
		 * Give an object to a player.
		 */
		public function giveObjectTo (player:CellInteractions) :void
		{			
			player.receiveItem(_item);
		}
		
		public static function random () :ObjectBox 
		{
			return new ObjectBox(randomItem());
		}

		protected static function randomItem () :Item
		{
			const choice:int = Math.round(Math.random() * 6) 	
			switch (choice) {
				case 0: return new Teleporter();
				case 1: return new OilCan();
				case 2: return new Ladder(1);
				case 3: return new Ladder(1);
				case 4: return new Ladder(3);
				case 5: return new Ladder(5);
				case 6: return new Spring();
				case 7: return new OilCan();
				default : return new Ladder(0); 
			}
		}	
			
				
		protected var _item:Item;
	}
}