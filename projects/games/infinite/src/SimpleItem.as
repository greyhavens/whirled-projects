package
{
	import flash.display.DisplayObject;
	
	import sprites.ItemSprite;

	public class SimpleItem extends ItemBase
	{
		public function SimpleItem()
		{
			super();
		}
		
		override public function get view () :DisplayObject
		{
			if (_sprite == null) {
				_sprite = new ItemSprite(initialAsset);
				registerEventHandlers(_sprite);
			}
			return _sprite;;
		}
		
		public function get initialAsset () :Class
		{
			return errorItem;
		}
		
		protected var _sprite:ItemSprite;
	}
}