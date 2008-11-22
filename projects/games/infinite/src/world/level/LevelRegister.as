package world.level
{
	import world.Player;
	import world.World;
	
	public class LevelRegister
	{
		public function LevelRegister(world:World)
		{
			_factory = new LevelFactory(world);
			_levels[FIRST_LEVEL] = _factory.makeLevel(FIRST_LEVEL);
		}

        /**
         * A player enters the system.
         */
        public function playerEnters(player:Player) :void
        {
        	const level:Level = find(FIRST_LEVEL);
        	player.enterLevel(level);
        }

        public function nextLevel(player:Player) :void
        {
            const level:Level = find(player.level.number + 1);
            player.enterLevel(level);
        }
        
        public function find(level:int) :Level
        {
        	var found:Level = _levels[level];
        	if (found == null) {
        	    found = _factory.makeLevel(level);
        	    _levels[level] = found;
        	}
        	return found;
        }
 
        public static const FIRST_LEVEL:int = 1;
        protected const _levels:Array = new Array();
        protected var _factory:LevelFactory;
	}
}