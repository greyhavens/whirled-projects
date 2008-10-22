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
			switch(level) {
				case LevelRegister.FIRST_LEVEL:
				    return new Level(level, Level.DEFAULT_HEIGHT, new SimpleBoard());				
			}				
					
			return new Level(level, Level.DEFAULT_HEIGHT, new BlankBoard());			
		}
	}
}