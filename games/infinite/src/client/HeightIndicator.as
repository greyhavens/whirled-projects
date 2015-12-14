package client
{
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
			refresh(); 
		}
		
		public function set top (top:int) :void
		{
			_top = top;
			refresh();
		}
		
		public function set current (current:int) :void
		{
			_current = -current;
			refresh();
		}
		
		protected function refresh () :void
		{
			const value:int = _top - _current;
			_textField.htmlText = "<p align='center'><font face='Helvetica, Arial, _sans' size='50'>"+String(value)+"</font></p>";
		}
		
		protected var _current:int;
		protected var _top:int;
		protected var _textField:TextField;
	}
}