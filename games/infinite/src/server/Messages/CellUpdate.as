package server.Messages
{
	import flash.utils.ByteArray;
	
	import world.Cell;
	
	public class CellUpdate implements Serializable
	{
	    public var level:int;		
		
		public function CellUpdate(level:int)
		{
			this.level = level;
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

        public function addVicinity (vicinity:String) :void
        {
            _vicinities.push(vicinity);
        }

        public function get vicinities () :Array
        {
            return _vicinities;
        }

        public function addState (state:CellState) :void
        {
        	_states.push(state);
        }

        public function get states () :Array
        {
        	return _states;
        }

        public function writeToArray (array:ByteArray) :ByteArray
        {
        	array.writeInt(level);
        	array.writeInt(_states.length);
        	for each (var state:CellState in _states) {
        		state.writeToArray(array);
        	}
        	array.writeInt(_vicinities.length);
        	for each (var vicinity:String in _vicinities) {
        	    array.writeUTF(vicinity);
        	}
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :CellUpdate
        {        	
        	const update:CellUpdate = new CellUpdate(array.readInt());
        	const states:int = array.readInt();
        	for (var i:int = 0; i < states; i++) {
        		update.addState(CellState.readFromArray(array));
        	}
        	const vicinities:int = array.readInt();
        	for (var j:int = 0; j < vicinities; j++) {
        	    update.addVicinity(array.readUTF());
        	}
        	return update;
        } 
        
        protected var _states:Array = new Array();
        protected var _vicinities:Array = new Array(); 
	}
}