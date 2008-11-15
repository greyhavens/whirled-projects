package inventory
{
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import items.Item;
	
	import sprites.ItemSprite;
	
	public class ItemViewBuffer
	{
		public function ItemViewBuffer()
		{
		}

        public function store (item:Item, view:ItemSprite) :void
        {
        	_views[item] = view;
        }
        
        public function find (item:Item) :ItemSprite
        {
            const found:ItemSprite = _views[item];
            if (found == null) throw new Error("view buffer doesn't contain a view for "+item);
            return found;
        }
        
        public function take (item:Item) :DisplayObject
        {
        	const found:DisplayObject = find(item);
       		delete _views[item];
       		return found;
        }
        
        protected var _views:Dictionary = new Dictionary();
	}
}