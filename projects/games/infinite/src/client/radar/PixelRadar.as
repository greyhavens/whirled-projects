package client.radar
{
	import client.player.Player;
	import client.player.PlayerEvent;
	
	/**
	 * Show player positions on a grid.
	 */
	public class PixelRadar
	{
		public function PixelRadar()
		{
		}
		
		public function handlePathComplete(event:PlayerEvent) :void
		{
			
		}
		
		public function handleChangedLevel(event:PlayerEvent) :void
		{
			
		}

        public function set player (player:Player) :void
        {
        	_player = player;
        }

        protected var _player:Player;
	}
}