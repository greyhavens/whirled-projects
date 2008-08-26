package joingame.modes
{
	import com.whirled.contrib.simplegame.AppMode;
	import com.threerings.flash.SimpleTextButton;
	
	import joingame.*;
	
	public class GameOverMode extends AppMode
	{
		public function GameOverMode()
		{
			super();
		}
		
		
		override protected function setup ():void
		{
			var winningPlayerID :int = GameContext.gameState._currentSeatedPlayerIds[0];
			var _button :SimpleTextButton = new SimpleTextButton("Winning Player = " + winningPlayerID);
			_modeSprite.addChild(_button);
			_button.x = 100;
			_button.y = 100;
		}
		
		
		
	}
}