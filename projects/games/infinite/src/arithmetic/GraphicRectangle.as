package arithmetic
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class GraphicRectangle
	{		
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;
		
		public function GraphicRectangle(x:int, y:int, width:int, height:int) :void
		{
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}
		
		public function half (direction:Vector) :GraphicRectangle
		{
			var half:int;
			if (direction.equals(Vector.UP)) {
				return new GraphicRectangle(x,y, width, height / 2);					
			}
			if (direction.equals(Vector.DOWN)) {
				half = height / 2;
				return new GraphicRectangle(x,y + half, width, half);
			}
			if (direction.equals(Vector.LEFT)) {
				return new GraphicRectangle(x, y, width / 2, height);
			}
			if (direction.equals(Vector.RIGHT)) {
				half = width / 2;				
				return new GraphicRectangle(x + half, y, half, height);  
			}
			throw new Error("can only divide the rectangle by orthogonal vectors");
		}
		
		public function get center () :GraphicCoordinates
		{
			return new GraphicCoordinates(x + (width / 2), y + (height / 2));
		}
		
		public function get origin () :GraphicCoordinates
		{
			return new GraphicCoordinates(x, y);
		}
		
		public function get size () :Vector
		{
			return new Vector(width, height);
		}		
		
		public function get right () :int
		{
			return x + width;
		}
		
		public function get bottom () :int
		{
			return y + height;
		}
		
		public function paddedBy (padding:int) :GraphicRectangle
		{
			return new GraphicRectangle(
				x - padding,
				y - padding,
				width + padding,
				height + padding
			);
		}
		
		public function alignBottomRightTo (other:GraphicRectangle) :GraphicRectangle
		{
			return new GraphicRectangle(other.right - width, other.bottom - height, width, height);
		}	
	
		
		public static function fromRectangle (rect:Rectangle) :GraphicRectangle
		{
			return new GraphicRectangle(rect.x, rect.y, rect.width, rect.height);
		}
		
		public static function fromText (field:TextField) :GraphicRectangle
		{
			return new GraphicRectangle(field.x, field.y, field.textWidth, field.textHeight);
		}
		
		public static function fromDisplayObject (object:DisplayObject) :GraphicRectangle
		{
			return new GraphicRectangle(0,0, object.width, object.height);
		}
				
		public function toString () :String
		{
			return "Graphic Rectangle at: "+x+", "+y+" width: "+width+" height: "+height;
		}
	}
}