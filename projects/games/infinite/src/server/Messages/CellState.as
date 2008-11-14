package server.Messages
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellFactory;
	
	import flash.utils.ByteArray;
	
	import world.Cell;
	import world.Chronometer;
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
        public function update(clock:Chronometer, board:BoardInteractions) :void
        {
        	const current:Cell = board.cellAt(_position);
        	current.updateState(clock, board, this);
        }

        public function writeToArray (array:ByteArray) :ByteArray
        {
        	array.writeInt(_code);
        	_position.writeToArray(array);
        	array.writeObject(attributes);
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :CellState
        {
        	const read:CellState = new CellState(
        	   array.readInt(),
        	   BoardCoordinates.readFromArray(array)
        	)
        	read.attributes = array.readObject();
        	return read;
        }
        
        /**
         * Return an array of ints that can be used by a particular cell type to encode its own
         * state.
         */  
        public function get attributes () :Object
        {
        	return _attributes;
        }

        public function set attributes (object:Object) :void
        {
        	_attributes = object;
        }        
        
        public function newCell (old:Cell) :Cell
        {
        	return makeCell(old.owner, this);
        }
        
        public function get code () :int
        {
        	return _code;
        }
        
        public function get position () :BoardCoordinates
        {
        	return _position;
        }

        protected var _code:int;
        protected var _position:BoardCoordinates;
        protected var _attributes:Object
	}
}