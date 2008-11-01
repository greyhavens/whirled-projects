package arithmetic
{
	public class Vicinity
	{
		public function Vicinity(coords:BoardCoordinates)
		{
            _x = coords.x >> SCALE;
            _y = coords.y >> SCALE;
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
        
        public function get neighborhood () :Array
        {
        	if (neighbors!= null) {
        		return neighbors;
        	}
        	
            neighbors = new Array();            
            neighbors.push(code(_x-1, _y-1));
            neighbors.push(code(_x,_y-1));
            neighbors.push(code(_x+1, _y-1));
            neighbors.push(code(_x-1, _y));
            neighbors.push(code(_x,_y));
            neighbors.push(code(_x+1, _y));
            neighbors.push(code(_x-1, _y+1));
            neighbors.push(code(_x,_y+1));
            neighbors.push(code(_x+1, _y+1));
            return neighbors;
        }
                
        protected var _x:int;
        protected var _y:int;
        
        protected var neighbors:Array;      
                       
        protected static const SCALE:int = 4;; 
 	}
}