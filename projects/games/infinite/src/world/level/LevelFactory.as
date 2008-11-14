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
			return new Level(_world, level, Level.DEFAULT_HEIGHT, new BlankBoard());			
		}
		
		protected var _world:World;
	}
}