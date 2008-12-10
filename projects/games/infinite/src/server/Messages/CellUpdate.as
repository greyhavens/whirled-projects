package server.Messages
{
	import flash.utils.ByteArray;
	
	import world.Cell;
	
	public class CellUpdate implements Serializable
	{
		public function CellUpdate(level:int)
		{
		}
		
		public function toString () :String
		{
			return "updates for "+_states.length+" cell(s)";
		}

        public function addCells (array:Array) :void
        {
        	//Log.debug("adding cells");
        	for each (var cell:Cell in array) {
        		//Log.debug("adding cell state: "+cell);
        		_states.push(cell.state);
        	}
        }

        protected function addState (state:CellState) :void
        {
        	_states.push(state);
        }

        public function get states () :Array
        {
        	return _states;
        }

        public function writeToArray (array:ByteArray) :ByteArray
        {
        	array.writeInt(_level);
        	for each (var state:CellState in _states) {
        		state.writeToArray(array);
        	}
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :CellUpdate
        {        	
        	const update:CellUpdate = new CellUpdate(array.readInt());
        	while (array.bytesAvailable) {
        		update.addState(CellState.readFromArray(array));
        	}
        	return update;
        } 
        
        protected var _level:int;
        protected var _states:Array = new Array(); 
	}
}