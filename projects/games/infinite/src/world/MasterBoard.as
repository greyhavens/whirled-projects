package world
{
    import arithmetic.BoardCoordinates;
    
    import com.whirled.game.NetSubControl;
    
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import world.board.Board;
    import world.board.BoardInteractions;
    
    /**
     * Server side board implementation for a single level that utilizes the distributed set to send out its state.
     * Writing changes to this implementation will distribute them out to the clients.
     */ 
    public class MasterBoard implements BoardInteractions
    {
        public function MasterBoard (levelNumber:int, height:int, startingBoard:Board, control:NetSubControl)
        {
            _slotName = slotName(levelNumber);
            _levelNumber = levelNumber;
            _height = height;
            _startingBoard = startingBoard;
            _control = control;
        }

        public static function positionToInt (height:int, coords:BoardCoordinates) :int
        {
            return (coords.x * height) + coords.y;
        }
        
        public static function intToPosition (height:int, pos:int) :BoardCoordinates
        {
            const y:int = pos % height;
            const x:int = (pos - y) / height;
            return new BoardCoordinates(x, y);
        }

        public function replace (cell:Cell) :void
        {
            _cache[cell.position.key] = cell;
            const array:ByteArray = new ByteArray();
            cell.state.writeToArray(array);
            _control.setIn(_slotName, positionToInt(_height, cell.position), array);  
        }
        
        public function cellAt (position:BoardCoordinates) :Cell
        {
            const found:Cell = _cache[position.key];
            if (found != null) {
                return found;
            }
            return _startingBoard.cellAt(position);
        }

        public static function slotName (number:int) :String
        {
            return "level-"+number;
        }
        
        public function get levelNumber () :int
        {
            return _startingBoard.levelNumber;
        }
        
        public function get startingPosition () :BoardCoordinates
        {
            return _startingBoard.startingPosition;
        }
 
        public var _levelNumber:int;
        public var _slotName:String
        public var _height:int;       
        public var _cache:Dictionary = new Dictionary();
        public var _control:NetSubControl;
        public var _startingBoard:Board;
    }
}