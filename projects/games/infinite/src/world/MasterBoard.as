package world
{
    import arithmetic.BoardCoordinates;
    import arithmetic.VoidBoardRectangle;
    
    import com.whirled.game.NetSubControl;
    
    import flash.events.EventDispatcher;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import world.board.Board;
    import world.board.BoardInteractions;
    
    /**
     * Server side board implementation for a single level that utilizes the distributed set to send out its state.
     * Writing changes to this implementation will distribute them out to the clients.
     */ 
    public class MasterBoard extends EventDispatcher implements BoardInteractions 
    {
        public function MasterBoard (levelNumber:int, height:int, startingBoard:Board, control:NetSubControl)
        {
            _control = control;
            _slotName = slotName(levelNumber);
            _levelNumber = levelNumber;
            this.height = height;
            _startingBoard = startingBoard;
        }        

        /**
         * Convert a positive or negative integer into a magnitude only value without
         * losing information, but interleaving negatives numbers as odds, and positives
         * as evens.
         */ 
        public static function mag (i:int) :int
        {
        	if (i < 0) {
        		return (i * -2) + 1;
        	} else {
        		return (i * 2);
        	}
        }
        
        /**
         * Recover an integer from a magnitude only value but de-interleaving odds into
         * negatives, and evens into positives.
         */ 
        public static function rec (i:int) :int
        {
        	if (i % 2 == 1) {
        		return (i-1) / -2;
        	} else {
        		return i / 2;
        	}
        }
        
        public static function positionToInt (height:int, coords:BoardCoordinates) :int
        {
            const h:int = height * 8; // factors - 3 for overplotting, 2 for negatives, 2 for safety
            const i:int = (mag(coords.x) * h) + mag(coords.y);
            return i;
        }
        
        public static function intToPosition (height:int, i:int) :BoardCoordinates
        {
        	const h:int = height * 8;
        	const magY:int = i % h;
        	const magX:int = (i - magY) / h
            return new BoardCoordinates(rec(magX), rec(magY));
        }

        public function replace (cell:Cell) :void
        {
            _cache[cell.position.key] = cell;
            const array:ByteArray = new ByteArray();
            cell.state.writeToArray(array);          
            _control.setIn(_slotName, positionToInt(_height, cell.position), array);
        }
        
        public function set height (val:int) :void
        {
            _control.setIn(_slotName+"-height", _levelNumber, val);
            _height = val;            
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
 
        public static function arrayToString(array:ByteArray) :String
        {
        	var text:String = "";
        	var hex:String = "";
        	for (var i:int = 0; i < array.length; i++ ) {
        		var c:int = array[i];
        		hex += d2h(c) + " ";
        		if (c > 32 && c < 127) {
            		text += String.fromCharCode(c);
                } else {
            		text += ".";
            	}
            }
            return "[ "+hex+": " + text+" ]";
        }
 
		protected static function d2h (d:int) : String {
		    var c:Array = [ '0', '1', '2', '3', '4', '5', '6', '7', '8',
		            '9', 'A', 'B', 'C', 'D', 'E', 'F' ];
		    if( d > 255 ) d = 255;
		    var l:int = d / 16;
		    var r:int = d % 16;
		    return c[l]+c[r];
		}
		 
        public var _levelNumber:int;
        public var _slotName:String
        public var _height:int;       
        public var _cache:Dictionary = new Dictionary();
        public var _control:NetSubControl;
        public var _startingBoard:Board;
    }
}