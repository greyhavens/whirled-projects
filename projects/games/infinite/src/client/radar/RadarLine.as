package client.radar
{
	import arithmetic.Vector;
	
	import client.player.Player;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import graphics.DirectionArrow;
	
	import sprites.SpriteUtil;

    /**
     * A single line in the radar.
     */ 
	public class RadarLine extends Sprite
	{
		public function RadarLine(player:Player, direction:Vector)
		{			
			super();
			
			// white background
			SpriteUtil.addBackground(this, 200, 25, SpriteUtil.YELLOW, 0.8);
			
			// black border
			SpriteUtil.addBorder(this, 200, 25, 1);
			
			_text = new TextField();
			addChild(_text);
			
			_arrow = new DirectionArrow(direction);
			addChild(_arrow);
			_arrow.x = 175;
			_arrow.y = 0;

            _text.y = 2;
            _text.width = 175;
            _text.htmlText = "<font face='Helvetica, Arial, _sans' size='18'>&nbsp;"+player.name+"</font>";			
		}
		
		protected var _text:TextField;
		protected var _arrow:DirectionArrow;	
	}
}