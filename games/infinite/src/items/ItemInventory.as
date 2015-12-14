package items
{
	public interface ItemInventory
	{
		function addItem (item:Item) :void;
		
		function addItemAt (position:int, item:Item) :void;
		
		function removeItem (item:Item) :void;
	}
}