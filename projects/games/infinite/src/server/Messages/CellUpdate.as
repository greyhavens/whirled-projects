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
        	for each (var cell:Cell in array) {
        		_states.push(cell.state);
        	}
        }

        public function get states () :Array
        {
        	return _states;
        }

        public function writeToArray (array:ByteArray) :ByteArray
        {
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :CellUpdate
        {
        	return new CellUpdate();
        } 
        
        protected var _states:Array = new Array(); 
	}
}