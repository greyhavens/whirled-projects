package world
{
	import items.Item;
	
	public class Inventory
	{
		public function Inventory()
		{
		}

		public function add(item:Item) :void
		{
			_items.push(item);
		}
		
		public function get full () :Boolean
		{
			return _items.length >= MAX_SIZE;	
		}
		
		protected var _items:Array = new Array();
		
		protected static const MAX_SIZE:int = 8;
	}
}