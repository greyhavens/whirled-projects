package arithmetic
{
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
		
		public function get origin () :GraphicCoordinates
		{
			return new GraphicCoordinates(x, y);
		}
		
		public function get right () :int
		{
			return x + width;
		}
		
		public function get bottom () :int
		{
			return y + height;
		}
		
		public function toString () :String
		{
			return "Graphic Rectangle at: "+x+", "+y+" width: "+width+" height: "+height;
		}
	}
}