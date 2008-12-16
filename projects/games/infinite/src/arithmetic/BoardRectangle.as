package arithmetic
{
	import flash.geom.Rectangle;
	
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
		
		/**
		 * Pad this rectangle by a percentage, and return it.  If a minimum is 
		 * provided, pad by a minimum of that amount.  The aspect ratio isn't really
		 * something we care about.
		 */
		public function percentPad (percent:int, minimum:int = 0) :BoardRectangle
		{
			var newWidth:int = (width * percent) / 100;
			var newHeight:int = (height * percent) / 100;			
			var hBorder:int = (width - newWidth) /2;
			var vBorder:int = (height - newHeight) /2;

            if (hBorder < minimum) {
            	newWidth = width + (minimum * 2);
            	hBorder = minimum;
            }			
			
			if (vBorder < minimum) {
				newHeight = height + (minimum * 2);
				vBorder = minimum;
			}
			
			return new BoardRectangle(x - hBorder, y - vBorder, newWidth, newHeight);
		}
		
		public function get left () :int
		{
			return x;
		}
		
		public function get top () :int
		{
			return y;
		}
		
		/**
		 * Return true if this rectangle contains the one that has been passed in.
		 */
		public function containsRectangle (other:BoardRectangle) :Boolean
		{
			return left <= other.left && top <= other.top && right >= other.right &&
			    bottom >= other.bottom;
		}
		
		/**
		 * Return the smallest rectangle that contains both this rectangle and the one
		 * supplied.
		 */
		public function union (other:BoardRectangle) :BoardRectangle
		{
			var tlX:int = x < other.x ? x : other.x;
			var tlY:int = y < other.y ? y : other.y;
			var brX:int = right > other.right ? right : other.right;
			var btY:int = bottom > other.bottom ? bottom : other.bottom;
			return new BoardRectangle(tlX, tlY, brX - tlX, btY - tlY);
		}
		
		public function get aspectRatio () :Number
		{
			return Number(width) / Number(height);
		}
	}
}