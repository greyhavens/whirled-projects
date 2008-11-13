package world.level
{	
	import cells.CellWorld;
	
	import world.board.*;
	
	public class LevelFactory
	{
		public function LevelFactory(world:CellWorld)
		{
			_world = world;
		}
		
		public function makeLevel(level:int) :Level
		{					
			return new Level(level, Level.DEFAULT_HEIGHT, new BlankBoard(_world));			
		}
		
		protected var _world:CellWorld;
	}
}