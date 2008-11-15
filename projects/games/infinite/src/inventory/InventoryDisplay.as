package inventory
{	
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import client.Client;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import items.Item;
	import items.ItemViewFactory;
	
	import sprites.*;
	
	public class InventoryDisplay extends EventDispatcher
	{
		public function InventoryDisplay(client:Client, width:int, height:int)
		{
			_client = client;
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
		
		public function removeItemAt (position:int) :void
		{
			var toRemove:Item = _items[position];
			if (toRemove != null) {
				// remove the selected item
				_view.removeChild(_viewBuffer.take(toRemove));
			
			    // if it wasn't the last item, we need to adjust the set.
			    if (position < _items.length - 1) {
					// shunt the others over
					for (var i:int = position; i < _items.length - 1; i++) {
						var shiftLeft:Item = _items[i+1];
	                    _items[i] = shiftLeft
	                    var sprite:ItemSprite = _viewBuffer.find(shiftLeft);
	                    sprite.position = i;
	                    positionItem(sprite, i);
	                }                
	    		}
                // remove either the duplicated one at the end
                _items.pop();
            }
		}
				
		protected function displayItem (item:Item, position:int) :void
		{
			const sprite:ItemSprite = _itemViews.viewOf(item);
			sprite.position = position;
			sprite.addEventListener(MouseEvent.CLICK, handleItemClicked);
			_view.addChild(sprite);
			positionItem(sprite, position);
			_viewBuffer.store(item, sprite);
		}
		
		protected function handleItemClicked (event:MouseEvent) :void
		{
			_client.itemClicked((event.target as ItemSprite).position);
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
		protected var _client:Client;
		
		/**
		 * The number of items that can be stored in the inventory.
		 */
		protected static const capacity:int = 8;
	}
}