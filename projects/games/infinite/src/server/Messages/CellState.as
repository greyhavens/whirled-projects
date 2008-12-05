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
		public function CellState(ownerId:int, code:int, position:BoardCoordinates)
		{
		    _ownerId = ownerId;
			_code = code;
			_position = position;
		}

        /**
         * Apply this state to the board.
         */
        public function update(owners:Owners, clock:Chronometer, board:BoardInteractions) :void
        {
        	const current:Cell = board.cellAt(_position);
        	current.updateState(owners, clock, board, this);
        }

        public function writeToArray (array:ByteArray) :ByteArray
        {
            array.writeInt(_ownerId);
        	array.writeInt(_code);
        	_position.writeToArray(array);
        	array.writeObject(attributes);
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :CellState
        {
        	const read:CellState = new CellState(
        	   array.readInt(),
        	   array.readInt(),
        	   BoardCoordinates.readFromArray(array)
        	)
        	read.attributes = array.readObject();
        	return read;
        }
        
        /**
         * Return an attributes object that can be used by a cell to encode the specifics of its state.
         */  
        public function get attributes () :Object
        {
            // return a blank attributes object rather than a null
            // this also means that this method can be used to set the 
            // attributes, which is permissible.
            if (_attributes == null) {
                _attributes = new Object();
            }
        	return _attributes;
        }

        public function set attributes (object:Object) :void
        {
        	_attributes = object;
        }        
        
        public function newCell (owners:Owners, old:Cell) :Cell
        {
        	return makeCell(owners.findOwner(_ownerId), this);
        }
        
        public function get code () :int
        {
        	return _code;
        }
        
        public function get position () :BoardCoordinates
        {
        	return _position;
        }

        protected var _ownerId:int;
        protected var _code:int;
        protected var _position:BoardCoordinates;
        protected var _attributes:Object
	}
}