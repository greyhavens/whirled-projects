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
     * 'read only' board implementation based on the distributed set.
     */ 
    public class DistributedBoard extends EventDispatcher implements BoardInteractions
    {
        public function DistributedBoard(height:int, owners:Owners, clock:Chronometer, startingBoard:Board, control:NetSubControl)
        {
            _height = height;
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
            if (event.name == _slotName) {
                _updated[event.key] = true;
            }
            dispatchEvent(new BoardEvent(BoardEvent.CELL_UPDATED, 
                MasterBoard.intToPosition(_height, event.key)));
        }
        
        public function cellAt(coords:BoardCoordinates) :Cell
        {
        	// return the cached cell if there is one
            const cached:Object = _cache[coords.key]
            var original:Cell;
            if (cached is Cell) {
            	// if there's a cached cell, start with it
                const cell:Cell = cached as Cell;
                const pos:int = MasterBoard.positionToInt(_height, cell.position);
                if (_updated[pos] == null) {
                	// if the cached cell hasn't been updated, return it
                    return cached as Cell;
                }
                // the cell has been updated so we're going to start with it an apply any changes                
                original = cell;                
                // clear the update mark
                delete _updated[pos];
            } else {
            	// otherwise start with the starting board from the cell
            	original = _startingBoard.cellAt(coords);
            }
            
            // see if there is a distributed state for the cell
            const state:CellState = state(coords);
            if (state == null) {
            	// if there is no state, then return what we found in the cache or from the 
            	// starting board.
                return original;
            }
            
            // if there is a state, then apply it to the default, cache the result and return it
            // cache anyway - since the update may be just a state change
            _cache[coords.key] = original;
            original.updateState(_owners, _clock, this, state);
            // read out of the cache since the original cell may have replaced itself
            return _cache[coords.key] as Cell;  
        }
        
        public function replace (cell:Cell) :void
        {
            _cache[cell.position.key] = cell;
        }

        protected function state(coords:BoardCoordinates) :CellState
        {            
        	const slot:Object = _control.get(_slotName);
        	if (slot is Dictionary)
        	{
	        	const found:Object = 
	        	  (slot as Dictionary)[MasterBoard.positionToInt(_height, coords)]
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

        protected var _height:int;
        protected var _owners:Owners;
        protected var _clock:Chronometer;
        protected var _startingBoard:Board;
        protected var _control:NetSubControl;
        protected var _slotName:String;
        protected var _cache:Dictionary = new Dictionary();
        protected var _updated:Dictionary = new Dictionary();        
    }
}
