package inventory
{	
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	import items.Item;
	import items.ItemInventory;
	import items.ItemViewFactory;
	
	import sprites.*;
	
	public class InventoryDisplay extends EventDispatcher
	{
		public function InventoryDisplay(width:int, height:int)
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
			
		public function addItemAt (position:int, item:Item) :void
		{
			_items[position] = item;
			displayItem(item, position);
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
					_view.removeChild(_viewBuffer.take(item));					
					var last:int = _items.length - 1;
					var j:int;
					for (j = i; j < last; j++) {
						var shiftLeft:Item = _items[j+1];
						_items[j] = shiftLeft;
						positionItem(_viewBuffer.find(shiftLeft), j);
					}
					_items.pop();
					break;
				}
			}
		}
			
		protected function displayItem (item:Item, position:int) :void
		{
			Log.debug ("inventory displaying "+item);
			const sprite:ItemSprite = _itemViews.viewOf(item);
			sprite.position = position;
			_view.addChild(sprite);
			positionItem(sprite, position);
		}
		
		protected function positionItem (object:DisplayObject, position:int) :void
		{
			const offset:Vector = positioningUnit.multiplyByVector(new Vector(position, 0));
			Geometry.position(object, GraphicCoordinates.ORIGIN.translatedBy(offset));			
		}
		
		protected var _viewBuffer:ItemViewBuffer = new ItemViewBuffer();	
	    protected var _itemViews:ItemViewFactory = new ItemViewFactory();
	
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