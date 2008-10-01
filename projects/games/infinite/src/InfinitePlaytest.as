package {
	import com.threerings.parlor.game.client.GameController;
	import com.whirled.game.GameControl;
	
	import flash.display.Sprite;
	
	import sprites.*;

	[SWF(width="700", height="500")]
	public class InfinitePlaytest extends Sprite
	{
		public function InfinitePlaytest()
		{
			_gameControl = new GameControl(this);
			
			trace ("game controller connected: "+_gameControl.isConnected());
			
			var simple:Sprite = new SimplePlaytest();
			addChild(simple);
		}				
		
		protected var _gameControl:GameControl;
	}
}