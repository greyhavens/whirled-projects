package server.Messages
{
	import flash.utils.ByteArray;
	
	import world.level.Level;

    /**
     * An update containing the current positions of all the players on a given level.
     */
	public class LevelUpdate implements Serializable
	{
		public function LevelUpdate()
		{
			
		}

        public function add (position:PlayerPosition) :void
        {        	
        	_positions.push(position);
        }

        public function get positions () :Array
        {
        	return _positions;
        }

		public function writeToArray(array:ByteArray):ByteArray
		{
			for each (var position:PlayerPosition in _positions) {
				position.writeToArray(array);
			}
			return array;
		}
		
		public static function readFromArray(array:ByteArray) :LevelUpdate
		{
            const update:LevelUpdate = new LevelUpdate();
		    while (array.bytesAvailable) {
		    	update.add(PlayerPosition.readFromArray(array));
		    }
		    return update;
		}
		
		protected var _positions:Array = new Array();
	}
}