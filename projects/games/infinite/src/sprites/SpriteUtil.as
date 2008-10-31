package sprites
{	
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class SpriteUtil
	{
		public static function addBackground(s:Sprite, width:int, height:int, color:uint) :void
		{
			with(s.graphics) {
				beginFill(color, 1.0);
				drawRect(0,0, width, height);
				endFill();	
			}
		}
		
		public static function tint (s:Sprite, color:uint, alpha:Number) :void
		{
			Log.debug ("tint alpha "+alpha);
			const overlay:Sprite = new Sprite();
			const g:Graphics = overlay.graphics;
			g.beginFill(color, alpha);
			g.drawRect(0,0, s.width, s.height);
			g.endFill();
			s.addChild(overlay);
		}
		
		public static const LIGHT_GREY:uint = 0xA0A0A0;
		public static const GREY:uint = 0x606060;
		public static const WHITE:uint = 0xFFFFFF;
		public static const RED:uint = 0xFF0000;
	}
}