package world
{
	public class LevelRegister
	{
		public function LevelRegister()
		{
			_levels[FIRST_LEVEL] = new Level(FIRST_LEVEL, Level.DEFAULT_HEIGHT);
		}
        
        /**
         * A player enters the system.
         */
        public function playerEnters(player:Player) :void
        {
        	const level:Level = find(FIRST_LEVEL);
        	player.enterLevel(level);
        }
        
        protected function find(level:int) :Level
        {
        	const found:Level = _levels[level];
        	if (found == null) {
        		throw new Error("level "+level+" does not exist");
        	}
        	return found;
        }
 
        protected static const FIRST_LEVEL:int = 1; 
        protected const _levels:Array = new Array();
	}
}