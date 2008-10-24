package world
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.EventDispatcher;
	
	import world.level.*;
	
	public class Player extends EventDispatcher
	{
		public function Player(id:int)
		{
			_id = id;			
		}

        public function get id () :int 
        {
        	return _id;
        }

        public function enterLevel (level:Level) :void
        {
            _level = level;
            level.playerEnters(this);
            dispatchEvent(new LevelEvent(LevelEvent.LEVEL_ENTERED, level, this)); 
        }

        public function get position () :BoardCoordinates
        {
            return _position;
        }
        
        public function set position (coords:BoardCoordinates) :void
        {
        	_position = coords;
        	dispatchEvent(new PlayerEvent(PlayerEvent.MOVE_COMPLETED, this));
        }

        protected var _position:BoardCoordinates;
        protected var _level:Level;
        protected var _id:int;
	}
}