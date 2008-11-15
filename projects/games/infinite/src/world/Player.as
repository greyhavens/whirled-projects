package world
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellInteractions;
	
	import flash.events.EventDispatcher;
	
	import items.Item;
	import items.ItemPlayer;
	
	import paths.Path;
	
	import world.arbitration.MoveEvent;
	import world.level.*;
	
	public class Player extends EventDispatcher implements CellInteractions, ItemPlayer
	{
		public function Player(id:int)
		{
			_id = id;
			_inventory = new Inventory(this);
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
        	Log.debug("completing path "+_path);
            if (_path.finish.equals(coords)) {
            	_level.map(_path.finish);
            	_path = null;
            		
            	// now check whether there are consequences of landing on this cell
            	_level.arriveAt(this, coords);
            } else {
	            Log.warning("move to " + _path.finish + " completed with unexpected endpoint "+coords);
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
        
        public function canReceiveItem () :Boolean
        {
        	return (! _inventory.full);
        }
        
        public function receiveItem (item:Item) :void
        {
        	const position:int = _inventory.add(item);
        	dispatchEvent(new InventoryEvent(InventoryEvent.RECEIVED, this, item, position));
        }
        
        public function useItem (position:int) :void
        {
        	var found:Item = _inventory.item(position);
        	if (found != null) {
        		if (found.isUsableBy(this)) {
        			Log.debug("attempting to use "+found);
        			found.useBy(this);
        			_inventory.removeItem(position);
        		} else {
        			Log.debug("item is not usable");
        		}
        	}
        }
        
        public function cellAt (coords:BoardCoordinates) :Cell
        {
        	return _level.cellAt(coords);
        }
        
        public function get startingPosition () :BoardCoordinates
        {
        	return _level.startingPosition;
        }
        
        /**
         * Replace a cell on behalf of this player, and distribute the change to all interested parties.
         */ 
        public function replace (cell:Cell) :void
        {
        	_level.replace(cell);
        	cell.distributeState();
        }
        
        public function get name () :String
        {
        	return "player "+_id;
        }
        
        public function teleport () :void
        {
        	throw new Error("teleport not implemented yet");
        }
        
        protected var _path:Path;
        protected var _cell:Cell;
        protected var _level:Level;
        protected var _id:int;
        protected var _inventory:Inventory;
	}
}