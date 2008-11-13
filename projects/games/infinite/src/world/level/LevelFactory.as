package world.level
{	
	import world.board.*;
	
	public class LevelFactory
	{
		public function LevelFactory()
		{
		}
		
		public function makeLevel(level:int) :Level
		{					
			return new Level(level, Level.DEFAULT_HEIGHT, new BlankBoard());			
		}
	}
}