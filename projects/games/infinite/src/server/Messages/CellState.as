package server.Messages
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellFactory;
	
	import flash.utils.ByteArray;
	
	import world.Cell;
	import world.board.BoardInteractions;
	
	public class CellState extends CellFactory implements Serializable
	{
		public function CellState(code:int, position:BoardCoordinates)
		{
			_code = code;
			_position = position;
		}

        /**
         * Apply this state to the board.
         */
        public function update(board:BoardInteractions) :void
        {
        	const current:Cell = board.cellAt(_position);
        	current.updateState(board, this);
        }

        public function writeToArray (array:ByteArray) :ByteArray
        {
        	array.writeInt(_code);
        	_position.writeToArray(array);
        	for each (var value:int in _state) {
        		array.writeInt(value);
        	}
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :CellState
        {
        	const read:CellState = new CellState(
        	   array.readInt(),
        	   BoardCoordinates.readFromArray(array)
        	)
        	while (array.bytesAvailable) {
        	   read.addState(array.readInt());
        	}
        	return read;
        }
        
        /**
         * Return an array of ints that can be used by a particular cell type to encode its own
         * state.
         */  
        public function get state () :Array
        {
        	return _state;
        }
        
        protected function addState(value:int) :void
        {
        	_state.push(value);
        } 
        
        public function newCell (old:Cell) :Cell
        {
        	return makeCell(_code, old.owner, old.position);
        }
        
        public function get code () :int
        {
        	return _code;
        }

        protected var _code:int;
        protected var _position:BoardCoordinates;
        protected var _state:Array = new Array();
	}
}