package client
{
	import client.player.Player;
	
	import flash.utils.Dictionary;
	
	import sprites.PlayerSprite;
	
	public class PlayerViews
	{
		public function PlayerViews()
		{
		}

        public function add(player:Player, sprite:PlayerSprite) :void
        {
        	_views[player] = sprite;
        }
        
        public function take(player:Player) :PlayerSprite
        {
        	const found:PlayerSprite = _views[player] as PlayerSprite;
        	if (found != null) {
        		delete _views[player];
        	}
        	return found;
        }
        
        public function find(player:Player) :PlayerSprite
        {
        	return _views[player] as PlayerSprite;        	
        }

        protected var _views:Dictionary = new Dictionary();
	}
}