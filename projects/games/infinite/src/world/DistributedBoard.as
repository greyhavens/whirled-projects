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
    
    public class DistributedBoard implements BoardInteractions
    {
        public function DistributedBoard(startingBoard:Board, control:NetSubControl)
        {
            _startingBoard = startingBoard;
            _slotName = "level-" + levelNumber;
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
                delete _cache[intToPosition(event.key).key];
            }            
        }
        
        protected function positionToInt (coords:BoardCoordinates) :int
        {
            return (coords.x * _height) + coords.y;
        }
        
        protected function intToPosition (pos:int) :BoardCoordinates
        {
            const y:int = pos % _height;
            const x:int = (pos - y) / _height;
            return new BoardCoordinates(x, y);
        }
                
        public function cellAt(coords:BoardCoordinates) :Cell
        {
            const cached:Cell = _cache[coords.key] as Cell
            if (cached != null) {
                return cached;
            }
            const state:CellState = state(coords);
            if (state == null) {
                 return _startingBoard.cellAt(coords);
            }
            const original:Cell = _startingBoard.cellAt(coords);
            original.updateState(_owners, _clock, this, state);
            return cached  
        }
        
        public function replace (cell:Cell) :void
        {
            _cache[cell.position.key] = cell;
        }

        protected function state(coords:BoardCoordinates) :CellState
        {            
            const array:ByteArray = (_control.get(_slotName) as Dictionary)[coords.key] as ByteArray;
            if (array != null) {
                return CellState.readFromArray(array);
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
        protected var _cache:Dictionary;
    }
}