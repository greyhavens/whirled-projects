package client.radar
{
	import arithmetic.Vector;
	
	import client.player.Player;
	import client.player.PlayerEvent;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import graphics.DirectionArrow;
	
	import sprites.SpriteUtil;

    /**
     * A single line in the radar.
     */ 
	public class RadarLine extends Sprite
	{
		public function RadarLine(player:Player, localPlayer:Player)
		{			
			super();
			_player = player;
			_localPlayer = localPlayer;
			
			// white background
			SpriteUtil.addBackground(this, 200, 25, SpriteUtil.YELLOW, 0.8);
			
			// black border
			SpriteUtil.addBorder(this, 200, 25, 1);
			
			_text = new TextField();
			addChild(_text);
			
			const direction:Vector = localPlayer.position.distanceTo(player.position);
			
			_arrow = new DirectionArrow(direction);
			addChild(_arrow);
			_arrow.x = 175 + 12;
			_arrow.y = 12;

            _text.y = 2;
            _text.width = 175;
            _text.htmlText = "<font face='Helvetica, Arial, _sans' size='18'>&nbsp;"+player.name+"</font>";			
		}

        public function startTracking () :void
        {
            _player.addEventListener(PlayerEvent.PATH_COMPLETED, handlePathCompleted);
            _localPlayer.addEventListener(PlayerEvent.PATH_COMPLETED, handlePathCompleted);
        }
        
        public function stopTracking () :void
        {
        	_localPlayer.addEventListener(PlayerEvent.PATH_COMPLETED, handlePathCompleted);
            _player.removeEventListener(PlayerEvent.PATH_COMPLETED, handlePathCompleted);            
        }
        
        /**
         * Handle an update to either the local player, or the player this line is pointing
         * at by adjusting the angle of the arrow.
         */
        protected function handlePathCompleted (event:PlayerEvent) :void
        {        	   
            const angle:Number = 
                _localPlayer.position.distanceTo(_player.position).rotation;

            _arrow.rotation = angle;
        }        
        
        public function get player () :Player
        {
            return _player;
        }

        protected var _player:Player;
        protected var _localPlayer:Player;		
		protected var _text:TextField;
		protected var _arrow:DirectionArrow;	
	}
}