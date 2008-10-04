package {
	import com.whirled.game.GameControl;
	
	import flash.display.Sprite;
	
	import sprites.*;

	[SWF(width="700", height="500")]
	public class InfinitePlaytest extends Sprite
	{
		public function InfinitePlaytest()
		{
			_gameControl = new GameControl(this);
			
			if (_gameControl.isConnected()) {
				addChild(new DistributedPlayTest(_gameControl));
			} else {
				addChild(new LocalPlayTest());				
			}			
		}				

		/**
		 * The compiler in flexbuilder starts from this class and compiles all of the reachable code.
		 * Under normal circumstances, this means that the server code isn't built.   This method
		 * is never called, but is used to create reachability from the 'main' client class to the server
		 * code.
		 */
		public function compileServer () :void
		{
			const server:Server = new Server();
		}
		
		protected var _gameControl:GameControl;
	}
}