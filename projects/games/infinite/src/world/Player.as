package world
{
	import world.level.*;
	
	public class Player
	{
		public function Player(id:int)
		{
			_id = id;
		}

        public function get id () :int 
        {
        	return id;
        }

        public function enterLevel (level:Level) :void
        {
            _level = level;
            level.playerEnters(this);
        }

        protected var _level:Level;
        protected var _id:int;
	}
}