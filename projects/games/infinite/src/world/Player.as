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
            return _cell.position;
        }
        
        public function set cell (cell:Cell) :void
        {
        	_cell = cell;
        	dispatchEvent(new PlayerEvent(PlayerEvent.MOVE_COMPLETED, this));
        }
        
        public function get cell () :Cell
        {
        	return _cell;
        }
        
        public function proposeMove (coords:BoardCoordinates) :void
        {
        	_level.proposeMove(this, coords);
        }
        
        public function get level () :Level
        {
        	return _level;
        }
        
        protected var _cell:Cell;
        protected var _level:Level;
        protected var _id:int;
	}
}