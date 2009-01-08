package world
{
    import arithmetic.BoardCoordinates;
    
    import com.whirled.game.NetSubControl;
    import com.whirled.net.ElementChangedEvent;
    
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import server.Messages.CellState;
    
    import world.board.Board;
    import world.board.BoardInteractions;
    
    /**
     * 'read only' board implementation based on the distributed set. 'replace' is only used by local objects to
     * cache the appropriate state.
     */ 
    public class DistributedBoard extends EventDispatcher implements BoardInteractions
    {
        public function DistributedBoard(owners:Owners, clock:Chronometer, startingBoard:Board, control:NetSubControl)
        {
            _owners = owners;
            _clock = clock; 
            _startingBoard = startingBoard;
            _slotName = MasterBoard.slotName(startingBoard.levelNumber);
            _control = control;
            _control.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);            
        }
        
        /**
         * Handle an element being changed by marking the cell as changed.
         * Next time the object is read from the board, the state update can be applied.
         */
        public function handleElementChanged (event:ElementChangedEvent) :void
        {
        	if (event.name != _slotName) {
        		return;
        	}
        	
            Log.debug("DISTRIBUTED BOARD - handling state changed. height: "+height+" name: "+event.name);
            // find out whether the changed element was cached
            const coords:BoardCoordinates = MasterBoard.intToPosition(height, event.key);
            const cached:Object = _cache[coords.key]
            if (cached is Cell) {
                Log.debug("STATE IS CACHED  - key: "+event.key+" coords: "+coords);
                // if we have a cached cell, then it may be in use and we update the state of the cell immediately
                const cell:Cell = cached as Cell;
                const state:CellState = state(coords);
                if (state == null) {
                    Log.debug("STATE IS NULL");
                }
                cell.updateState(_owners, _clock, this, state);
                // an event will be generated if the update causes the cell to be replaced.
            } else {
                Log.debug("STATE IS NOT CACHED");
            }
        }
        
        public function cellAt(coords:BoardCoordinates) :Cell
        {
        	// return the cached cell if there is one
            const cached:Object = _cache[coords.key]
            if (cached is Cell) {
                return cached as Cell;
            }
            
            // cache the result from the starting board
            const original:Cell = _startingBoard.cellAt(coords);
            _cache[coords.key] = original;
            
            // see if there is a distributed state for the cell
            const state:CellState = state(coords);
            if (state == null) {
            	// if there is no state, then return what we found in the cache or from the 
            	// starting board.
                return original;
            }
            
            // apply the state
            original.updateState(_owners, _clock, this, state);
            // read out of the cache since the original cell may have replaced itself
            return _cache[coords.key] as Cell;  
        }
        
        public function replace (cell:Cell) :void
        {
            _cache[cell.position.key] = cell;
            Log.debug("CELL REPLACED - GENERATING EVENT");                        
            dispatchEvent(new BoardEvent(BoardEvent.CELL_REPLACED, cell.position));
        }

        protected function state(coords:BoardCoordinates) :CellState
        {            
        	const slot:Object = _control.get(_slotName);
        	if (slot is Dictionary)
        	{
	        	const found:Object = 
	        	  (slot as Dictionary)[MasterBoard.positionToInt(height, coords)]
	        	if (found is ByteArray) {
	        		const array:ByteArray = found as ByteArray;
                    array.position = 0;
	        		return CellState.readFromArray(array);
	        	}
	        }
        	return null;
        }
        
        public function get levelNumber () :int
        {
            return _startingBoard.levelNumber;
        }

        public function get startingPosition () :BoardCoordinates
        {
            return _startingBoard.startingPosition;
        } 

        public function get height () :int 
        {
            return (_control.get(_slotName+"-height") as Dictionary)[_startingBoard.levelNumber]            
        }

        protected var _owners:Owners;
        protected var _clock:Chronometer;
        protected var _startingBoard:Board;
        protected var _control:NetSubControl;
        protected var _slotName:String;
        protected var _cache:Dictionary = new Dictionary();
    }
}
