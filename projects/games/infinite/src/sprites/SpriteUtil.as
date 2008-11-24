package sprites
{	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class SpriteUtil
	{
		public static function addBackground(s:Sprite, width:int, height:int, color:uint, alpha:Number = 1.0) :void
		{
			with(s.graphics) {
				beginFill(color, alpha);
				drawRect(0,0, width, height);
				endFill();	
			}
		}
		
		public static function addBorder(s:Sprite, width:int, height:int, thickness:Number = 2, 
		  color:uint = 0x000000, alpha:Number = 1.0) :void
		{
			with(s.graphics) {
				lineStyle(thickness, color, alpha);
				drawRect(0,0, width,height);
			}
		}
		
		public static function tint (width:int, height:int, color:uint, alpha:Number) :DisplayObject
		{
			const overlay:Sprite = new Sprite();
			const g:Graphics = overlay.graphics;
			g.beginFill(color, alpha);
			g.drawRect(0,0, width, height);
			g.endFill();
			return overlay;
		}
		
		public static const BLACK:uint = 0x000000;
		public static const LIGHT_GREY:uint = 0xA0A0A0;
		public static const GREY:uint = 0x606060;
		public static const WHITE:uint = 0xFFFFFF;
		public static const RED:uint = 0xFF0000;
	}
}