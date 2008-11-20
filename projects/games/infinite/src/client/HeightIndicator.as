package client
{
	import arithmetic.Geometry;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import sprites.SpriteUtil;
	
	public class HeightIndicator extends Sprite
	{
		public function HeightIndicator()
		{
            // the height indicator is twice the width of an item
            SpriteUtil.addBackground(this, Config.itemSize.dx * 2, Config.itemSize.dy, SpriteUtil.WHITE);

			_top = 0;
			_current = 0;
			_textField = new TextField();
			addChild(_textField);
						
			Log.debug("height indicator size: "+width+", "+height);
			refresh(); 
            Log.debug("after refresh height indicator size: "+width+", "+height);
		}
		
		public function set top (top:int) :void
		{
			_top = top;
			refresh();
		}
		
		public function set current (current:int) :void
		{
			Log.debug("setting height indicator height to: "+current);
			_current = -current;
			refresh();
		}
		
		protected function refresh () :void
		{
			const value:int = _top - _current;
            Log.debug("height indicator update to "+value);
			_textField.text = String(value);
			// center the text field in the box
			//Geometry.centerTextIn(this, _textField);
		}
		
		protected var _current:int;
		protected var _top:int;
		protected var _textField:TextField;
	}
}