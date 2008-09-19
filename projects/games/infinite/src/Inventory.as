package
{	
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import sprites.*;
	
	public class Inventory extends EventDispatcher
	{
		public function Inventory(width:int, height:int)
		{
			_width = width;
			_height = height;
		}
		
		public function createView () :Sprite
		{
			const s:Sprite = new Sprite();
			SpriteUtil.addBackground(s, _width, _height, SpriteUtil.GREY);
			return s;
		}
		
		public function get view () :DisplayObject
		{
			if (_view == null) {
				_view = createView();
			}
			return _view;
		}
	
		public function isFull () :Boolean
		{
			return _items.length >= capacity;
		}
	
		public function addItem (item:Item) :void
		{
			_items.push(item);
			displayItem(item, _items.length - 1);
			item.addEventListener(ItemEvent.ITEM_CLICKED, handleItemClicked);
		}
		
		/**
		 * Remove an item from the inventory and shunt the other items over to the left.
		 */
		public function removeItem (item:Item) :void
		{
			var i:int;
			for (i = 0; i < _items.length; i++)
			{
				if (_items[i] == item) {
					_view.removeChild(item.view);					
					var last:int = _items.length - 1;
					var j:int;
					for (j = i; j < last; j++) {
						var item:Item = _items[j+1];
						_items[j] = item;
						positionItem(item,j);
					}
					_items.pop();
					break;
				}
			}
		}
		
		public function handleItemClicked (event:ItemEvent) :void
		{
			dispatchEvent(new ItemEvent(event.type, event.item));
		}
	
		public function displayItem (item:Item, position:int) :void
		{
			trace ("inventory displaying "+item);
			_view.addChild(item.view);
			positionItem(item, position);
		}
	
		public function positionItem (item:Item, position:int) :void
		{
			const offset:Vector = positioningUnit.multiplyByVector(new Vector(position, 0));
			GraphicCoordinates.ORIGIN.translatedBy(offset).applyTo(item.view);			
		}
	
		protected var positioningUnit:Vector = ItemSprite.UNIT.add(new Vector(10 ,0));
	
		// The actual items stored in the inventory.
		protected var _items:Array = new Array();
				
		protected var _width:int;
		protected var _height:int;				
		protected var _view:Sprite;
		
		/**
		 * The number of items that can be stored in the inventory.
		 */
		protected static const capacity:int = 8;
	}
}