package client.radar
{
	import arithmetic.Vector;
	
	import client.player.Player;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
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
			SpriteUtil.addBackground(this, 200, 25, SpriteUtil.WHITE, 0.8);
			
			// black border
			SpriteUtil.addBorder(this, 200, 25, 2);
			
			_text = new TextField();
			addChild(_text);
			
			_arrow = new DirectionArrow(direction);
			addChild(_arrow);
			_arrow.x = 175;
			_arrow.y = 0;
			
			_player = player;
			_direction = direction;
		}
		
		protected var _text:TextField;
		protected var _arrow:DisplayObject;		
		protected var _player :Player;
		protected var _direction :Vector;
	}
}