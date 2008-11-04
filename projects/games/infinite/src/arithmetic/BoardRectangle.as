package arithmetic
{
	import world.board.Board;
	
	public class BoardRectangle
	{
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;

		/**
		 * Create a new board rectangle.  The x and y coordinates denote the top left hand corner
		 * of the rectangle.  Increasing y denotes downwards movement.
		 */
		public function BoardRectangle (x:int, y:int, width:int, height:int) :void
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public function randomLocation () :BoardCoordinates
		{
			return new BoardCoordinates(x + (Math.random() * width), y + (Math.random() * height));
		}
		
		public function toString () :String
		{
			return "Board Rectangle at: "+x+", "+y+" width: "+width+" height: "+height;
		}
				
		public function translatedBy (offset:Vector) :BoardRectangle
		{
			return new BoardRectangle(
				x + offset.dx,
				y + offset.dy,
				width,
				height
			);
		}
		
		/**
		 * Two rectangles are equal if they have the same origin and the same dimensions
		 */
		public function equals (other:BoardRectangle) :Boolean
		{
			return other.x == x && other.y == y && other.width == width && other.height == height;
		}
		
		public function get origin () :BoardCoordinates
		{
			return new BoardCoordinates(x, y);
		}
		
		public function get bottom () :int
		{
			return y + height;
		}
		
		public function get right () :int 
		{
			return x + width;
		}
		
		/**
		 * Return true if this rectangle overlaps the other one supplied.
		 */
		public function overlaps (other:BoardRectangle) :Boolean
		{
			if (x + width < other.x) {
				return false;
			}
			
			if (other.x + other.width < x) {
				return false;
			}
			
			if (y + height < other.y) {
				return false;
			}
			
			if (other.y + other.height < y) {
				return false;
			}
			
			return true;
		}
		
		/**
		 * Return a vector representing the vertical offset between this rectangle
		 * and another one supplied.  (What would you need to add to this one to align
		 * it with the other one.
		 */
		public function offsetFrom (other:BoardRectangle) :Vector
		{
			return new Vector(
				this.x - other.x,
				this.y - other.y
			);
		}
		
		public function contains (point:BoardCoordinates) :Boolean
		{
			return point.x >= x && point.x < x + width && point.y >= y && point.y < y + height;
		}
		
		public function relativePosition (point:BoardCoordinates) :Vector 
		{
			return new Vector(
				point.x - x,
				point.y - y
			)
		}
	}
}