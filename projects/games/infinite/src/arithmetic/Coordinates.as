package arithmetic
{
	public class Coordinates
	{
		public function Coordinates(x:int, y:int)
		{ 
			_x = x;
			_y = y;
		}

		public function get x () :int 
		{
			return _x;
		} 
		
		public function get y () :int 
		{
			return _y;
		}
				
		public function toString () :String
		{
			return "position (" + _x + ", " + _y + ")";
		}
		
		public function get key () :String 
		{
			if (_key == null) {
				_key = _x+","+_y; 
			}
			return key;
		}
		
		protected var _key:String;
		protected var _x:int;
		protected var _y:int;	
	}
}