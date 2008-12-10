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
		
		public function makeLevel(number:int) :Level
		{					
		    const height:int = Level.MIN_HEIGHT + Math.pow(2, number);
			return new Level(_world, height, new BlankBoard(number, height));			
		}
		
		protected var _world:World;
	}
}