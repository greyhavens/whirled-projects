package arithmetic
{
	import flash.utils.ByteArray;
	
	import server.Messages.Neighborhood;
	import server.Messages.Serializable;
	
	public class Vicinity implements Serializable
	{
		public function Vicinity(x:int, y:int)
		{
			_x = x;
			_y = y;
		}
        
        public static function fromCoordinates(coords:BoardCoordinates) :Vicinity
        {
        	return new Vicinity(coords.x >> SCALE, coords.y >> SCALE);        	
        }
        
        public function get region () :BoardRectangle
        {
        	return new BoardRectangle(origin.x, origin.y, SQUARE, SQUARE);
        }
        
        /**
        * Return the origin of the region that this vicinity defines (i.e. the top
        * left corner of the square, in board coordinates);
        */
        public function get origin () :BoardCoordinates
        {
        	return new BoardCoordinates(_x << SCALE, _y << SCALE);
        }
        
        public function translate(v:Vector) :Vicinity
        {
        	return new Vicinity(
        	   _x + v.dx,
        	   _y + v.dy
        	);
        }
        
        protected function code (x:int, y:int) :String
        {
        	return x + "," + y;
        }
        
        public function toString () :String
        {
        	return "[" + key() + "]";
        }
        
        public function key () :String
        {
        	return code(_x, _y);
        }
        
        public function get neighborhood () :Neighborhood
        {
        	var hood:Neighborhood = new Neighborhood();
        	for each (var nearby:Vicinity in vicinitiesNearby) {
        		hood.add(nearby);
        	}
        	return hood;
        }
        
        public function get vicinitiesNearby () :Array
        {
        	if (neighbors!= null) {
        		return neighbors;
        	}
        	
            neighbors = new Array();
            neighbors.push(translate(Vector.NE));
            neighbors.push(translate(Vector.N));
            neighbors.push(translate(Vector.NW));
            neighbors.push(translate(Vector.E));
            neighbors.push(this);
            neighbors.push(translate(Vector.W));
            neighbors.push(translate(Vector.SE));
            neighbors.push(translate(Vector.S));
            neighbors.push(translate(Vector.SW));
            
            return neighbors;
        }
 
        public function writeToArray (array:ByteArray) :ByteArray
        {
        	array.writeInt(_x);
        	array.writeInt(_y);
        	return array;
        }
        
        public static function readFromArray (array:ByteArray) :Vicinity
        {
        	return new Vicinity(array.readInt(), array.readInt());
        }
                
        protected var _x:int;
        protected var _y:int;
        
        protected var neighbors:Array;      
                       
        protected static const SCALE:int = 4;
        public static const SQUARE:int = 1 << SCALE;
        
        // Constant vectors used to translate to the top left of the square in different
        // quadrants
        protected static const N:Vector = Vector.N.by(SQUARE);
        protected static const NE:Vector = Vector.NE.by(SQUARE);
        protected static const W:Vector = Vector.W.by(SQUARE);
 	}
}