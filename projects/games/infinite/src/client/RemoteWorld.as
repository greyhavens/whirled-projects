package client
{
	import com.whirled.game.GameControl;
	
	import flash.events.EventDispatcher;

	public class RemoteWorld extends EventDispatcher implements InfiniteWorld
	{
		public function RemoteWorld(gameControl:GameControl)
		{
			_gameControl = gameControl;
		}

        protected var _gameControl:GameControl		
	}
}