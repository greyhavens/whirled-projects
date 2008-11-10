package server.Messages
{
	import arithmetic.Vicinity;
	
	import flash.utils.ByteArray;
	
	public class Neighborhood implements Serializable
	{
		public function Neighborhood()
		{
		}

        public function isEmpty() :Boolean
        {
        	return _vicinities.length <= 0;
        }

        public function add(vicinity:Vicinity) :void
        {
        	_vicinities.push(vicinity);
        }
        
        public function writeToArray (array:ByteArray) :ByteArray
        {
            for each (var vicinity:Vicinity in _vicinities) {
            	vicinity.writeToArray(array);
            }
            return array;
        }

        public static function readFromArray (array:ByteArray) :Neighborhood
        {
        	const hood:Neighborhood = new Neighborhood();
        	while (array.bytesAvailable) {
        		hood.add(Vicinity.readFromArray(array));
        	}
        	return hood;
        }
        
        public function toString () :String
        {
        	var string:String = "neighborhood (";
        	var i:int;
        	for (i = 0; i < _vicinities.length ; i++) {
        		string += (_vicinities[i] as Vicinity).key();
        		if (i < _vicinities.length - 1) {
        			string += "|";
        		}
        	}
        	string += ")"
        	return string;
        }
        
        public function get vicinities () :Array
        {
        	return _vicinities;
        }

        protected var _vicinities:Array = new Array();
	}
}