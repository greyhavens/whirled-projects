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
        	const found:Level = _levels[level];
        	if (found == null) {
        		throw new Error("level "+level+" does not exist");
        	}
        	return found;
        }
 
        public static const FIRST_LEVEL:int = 1;
        protected const _levels:Array = new Array();
        protected var _factory:LevelFactory;
	}
}