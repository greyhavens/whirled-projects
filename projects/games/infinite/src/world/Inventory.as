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
		
		protected var _player:Player;
		
		protected var _items:Array = new Array();
		
		protected static const MAX_SIZE:int = 8;
	}
}