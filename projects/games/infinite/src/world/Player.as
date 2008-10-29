package world
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.EventDispatcher;
	
	import paths.Path;
	
	import world.arbitration.MoveEvent;
	import world.level.*;
	
	public class Player extends EventDispatcher 
	{
		public function Player(id:int)
		{
			_id = id;
			addEventListener(MoveEvent.PATH_START, handlePathStart);			
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
        
        /**
         * When movement starts, keep track of it.
         */ 
        public function handlePathStart (event:MoveEvent) :void
        {
        	_path = event.path;
        }
        
        public function moveComplete (coords:BoardCoordinates) :void
        {
            if (_path.finish.equals(coords)) {
            	_path = null;
            }
        }
        
        public function isMoving () :Boolean
        {
        	return _path != null;
        }
        
        override public function toString () :String
        {
        	return "world player "+_id;
        }
        
        protected var _path:Path;
        protected var _cell:Cell;
        protected var _level:Level;
        protected var _id:int;
	}
}