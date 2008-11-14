package world
{
	import items.Item;
	
	public class Inventory
	{
		public function Inventory(player:Player)
		{
			_player = player;
		}

		public function add(item:Item) :int
		{
			Log.debug(this+ " received "+item);
			return _items.push(item) -1 ;
		}
		
		public function get full () :Boolean
		{
			return _items.length >= MAX_SIZE;	
		}
		
		public function toString () :String
		{
			return "inventory";
		}
		
		public function item (position:int) :Item
		{
			return _items[position];
		}
		
		public function removeItem (position:int) :void
		{
			if (_items[position] != null) {
				// delete the item
				delete _items[position];
				
				// shunt the other items to the left
				for (var i:int = position + 1; i < _items.length; i++) {
					_items[i - 1] = _items[i];
				}
				
				// delete the duplicate item from the end
				_items.pop();
			}
		}
		
		protected var _player:Player;
		
		protected var _items:Array = new Array();
		
		protected static const MAX_SIZE:int = 8;
	}
}