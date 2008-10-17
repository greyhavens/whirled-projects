package
{	
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import items.Item;
	import items.ItemEvent;
	import items.ItemInventory;
	import items.ViewableItem;
	
	import sprites.*;
	
	public class Inventory extends EventDispatcher implements ItemInventory, Viewable
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
			const viewable:ViewableItem = item as ViewableItem;
			if (viewable != null) {
				_items.push(viewable);
				displayItem(viewable, _items.length - 1);
				item.addEventListener(ItemEvent.ITEM_CLICKED, handleItemClicked);
			} else {
				throw new Error("cannot add "+item+" that isn't viewable to the inventory.");
			}
		}
		
		/**
		 * Remove an item from the inventory and shunt the other items over to the left.
		 */
		public function removeItem (item:Item) :void
		{			
			const viewable:ViewableItem = item as ViewableItem;
			if (viewable != null) {
				var i:int;
				for (i = 0; i < _items.length; i++)
				{
					if (_items[i] == viewable) {
						_view.removeChild(viewable.view);					
						var last:int = _items.length - 1;
						var j:int;
						for (j = i; j < last; j++) {
							var shiftLeft:ViewableItem = _items[j+1];
							_items[j] = shiftLeft;
							positionItem(shiftLeft,j);
						}
						_items.pop();
						break;
					}
				}
			}
		}
		
		public function handleItemClicked (event:ItemEvent) :void
		{
			dispatchEvent(new ItemEvent(event.type, event.item));
		}
	
		protected function displayItem (item:ViewableItem, position:int) :void
		{
			trace ("inventory displaying "+item);
			_view.addChild(item.view);
			positionItem(item, position);
		}
	
		protected function positionItem (item:ViewableItem, position:int) :void
		{
			const offset:Vector = positioningUnit.multiplyByVector(new Vector(position, 0));
			Geometry.position(item.view, GraphicCoordinates.ORIGIN.translatedBy(offset));			
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