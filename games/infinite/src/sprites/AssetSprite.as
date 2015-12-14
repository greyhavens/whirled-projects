package sprites
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class AssetSprite extends Sprite
	{
		public function AssetSprite(asset:Class, width:int, height:int)
		{
			super();
			_asset = asset;
			_width = width;
			_height = height;
			addInstance();
		}
		
		/**
		 * Set the asset displayed by this sprite to a different class.
		 */
		public function set asset (asset:Class) :void
		{
			removeChild(_instance);
			_asset = asset;
			addInstance();
		}
		
		protected function addInstance() :void
		{
			_instance = new _asset();
			addChildAt(_instance, 0);
			this.width = _width;
			this.height = _height;
		}
		
		public function darken (amount:Number) :void
		{
			if (_overlay == null) {
    			_overlay = SpriteUtil.tint(_width * 2, _height * 2, SpriteUtil.GREY, amount);
    			_overlay.x = 0;
    			_overlay.y = 0;
    			addChild(_overlay);
			}
		}
		
		public function clearOverlay () :void
		{
			if (_overlay != null) {
    			removeChild(_overlay);
    			_overlay = null;
            }
		}		
		
		protected var _instance:DisplayObject;
		protected var _asset:Class;
		protected var _width:int;
		protected var _height:int;
		protected var _overlay:DisplayObject;
	}
}