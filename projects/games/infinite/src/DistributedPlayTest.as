package
{
	import com.whirled.game.GameControl;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import sprites.SpriteUtil;
	
	public class DistributedPlayTest extends PlayTest
	{
		public function DistributedPlayTest(gameControl:GameControl)
		{
			super();
			_gameControl = gameControl;
		}
		
		override public function get mode () :String 
		{
			return "client-server";
		}
					
		protected var _gameControl:GameControl;
	}	
}
