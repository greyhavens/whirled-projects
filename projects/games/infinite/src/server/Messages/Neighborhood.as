package server.Messages
{
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

        public function add(vicinity:String) :void
        {
        	_vicinities.push(vicinity);
        }
        
        public function writeToArray (array:ByteArray) :ByteArray
        {
            for each (var vicinity:String in _vicinities) {
            	array.writeUTF(vicinity);
            }
            return array;
        }

        public static function readFromArray (array:ByteArray) :Neighborhood
        {
        	const hood:Neighborhood = new Neighborhood();
        	while (array.bytesAvailable) {
        		hood.add(array.readUTF());
        	}
        	return hood;
        }
        
        public function toString () :String
        {
        	var string:String = "neighborhood (";
        	var i:int;
        	for (i = 0; i < _vicinities.length ; i++) {
        		string += _vicinities[i];
        		if (i < _vicinities.length - 1) {
        			string += "-";
        		}
        	}
        	string += ")"
        	return string;
        }

        protected var _vicinities:Array = new Array();
	}
}