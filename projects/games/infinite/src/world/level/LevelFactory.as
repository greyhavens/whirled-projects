package world.level
{	
	import world.World;
	import world.board.*;
	
	public class LevelFactory
	{
		public function LevelFactory(world:World)
		{
			_world = world;
		}
		
		public function makeLevel(level:int) :Level
		{					
		    const height:int = Level.MIN_HEIGHT + Math.pow(2, level);
			return new Level(_world, level, height, new BlankBoard(height));			
		}
		
		protected var _world:World;
	}
}