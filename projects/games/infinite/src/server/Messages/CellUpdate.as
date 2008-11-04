package server.Messages
{
	import flash.utils.ByteArray;
	
	import world.Cell;
	
	public class CellUpdate implements Serializable
	{
		public function CellUpdate()
		{
		}

        public function addCells (array:Array) :void
        {
        	Log.debug("adding cells");
        	for each (var cell:Cell in array) {
        		Log.debug("adding cell state: "+cell);
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
        	for each (var state:CellState in _states) {
        		state.writeToArray(array);
        	}
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :CellUpdate
        {
        	const update:CellUpdate = new CellUpdate();
        	while (array.bytesAvailable) {
        		update.addState(CellState.readFromArray(array));
        	}
        	return update;
        } 
        
        protected var _states:Array = new Array(); 
	}
}