package world
{
    import arithmetic.BoardCoordinates;
    
    import com.whirled.game.NetSubControl;
    import com.whirled.net.ElementChangedEvent;
    
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import server.Messages.CellState;
    
    import world.board.Board;
    import world.board.BoardInteractions;
    
    /**
     * 'read only' board implementation based on the distributed set.
     */ 
    public class DistributedBoard implements BoardInteractions
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
         * Handle an element being changed by simply deleting the cached object.  
         * If the object is needed again later it will be deserialized and cached then. 
         */
        public function handleElementChanged (event:ElementChangedEvent) :void
        {
            if (event.name == _slotName) {
                delete _cache[MasterBoard.intToPosition(_height, event.key).key];
            }            
        }
                        
        public function cellAt(coords:BoardCoordinates) :Cell
        {
        	// return the cached cell if there is one
            const cached:Object = _cache[coords.key]
            if (cached is Cell) {
            	return cached as Cell;
            }
            // otherwise see if there is a distributed state for the cell
            const state:CellState = state(coords);
            if (state == null) {
            	// if there is no state, then return the default for this board
            	Log.debug("returning cell from starting board for "+coords);
                return _startingBoard.cellAt(coords);
            }
            // if there is a state, then apply it to the default, cache the result and return it
            const original:Cell = _startingBoard.cellAt(coords);
            original.updateState(_owners, _clock, this, state);
            replace(original);
            return original;  
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
	        	const found:Object = (slot as Dictionary)[coords.key]
	        	if (found is ByteArray) {
	        		return CellState.readFromArray(found as ByteArray);
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
    }
}