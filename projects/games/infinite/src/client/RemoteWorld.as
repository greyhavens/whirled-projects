package client
{
	import com.whirled.game.GameControl;
	
	import flash.events.EventDispatcher;
	
	import world.ClientWorld;

	public class RemoteWorld extends EventDispatcher implements ClientWorld
	{
		public function RemoteWorld(gameControl:GameControl)
		{
			_gameControl = gameControl;
		}

        public function get worldType () :String
        {
        	return "shared";
        }

        protected var _gameControl:GameControl		
	}
}