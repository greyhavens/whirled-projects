package world.level
{	
	import com.whirled.game.NetSubControl;
	
	import world.World;
	import world.board.*;
	
	public class LevelFactory
	{
		public function LevelFactory(world:World, control:NetSubControl)
		{
			_world = world;
			_control = control;
		}
		
		public function makeLevel(number:int) :Level
		{					
		    const height:int = Level.MIN_HEIGHT + Math.pow(2, number);
			return new Level(_world, height, new BlankBoard(number, height), _control);			
		}
		
		protected var _world:World;
		protected var _control:NetSubControl;
	}
}