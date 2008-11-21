package arithmetic
{
	import flash.utils.ByteArray;
	
	import server.Messages.Serializable;
			
	public class BoardCoordinates implements Serializable
	{
	    public var x:int;
	    public var y:int;
	    public var key:String;
	    
		public function BoardCoordinates(x:int, y:int)		
		{ 
		    this.x = x;
		    this.y = y;
		    this.key = x + ","+ y;
		}
		
		public function toString () :String
		{
			return "board position ("+x+", "+y+")";
		}
		
		public function distanceTo (other:BoardCoordinates) :Vector
		{
			return new Vector(
				other.x - x,
				other.y - y
			);
		}

		public function translatedBy (v:Vector) :BoardCoordinates
		{
			return new BoardCoordinates(
				x + v.dx,
				y + v.dy
			)
		}
		
		public function graphicsCoordinates (
			boardOrigin:BoardCoordinates, graphicsOrigin:GraphicCoordinates) :GraphicCoordinates
		{
			return graphicsOrigin.translatedBy(boardOrigin.distanceTo(this).multiplyByVector(Config.cellSize));
		}
		
		public function above (other:BoardCoordinates) :Boolean
		{
			return this.x == other.x && this.y == other.y - 1; 
		}

		public function below (other:BoardCoordinates) :Boolean
		{
			return this.x == other.x && this.y == other.y + 1; 
		}
		
		public function onLeftOf (other:BoardCoordinates) :Boolean
		{
			return this.y == other.y && this.x == other.x - 1; 
		}
			
		public function onRightOf (other:BoardCoordinates) :Boolean
		{
			return this.y == other.y && this.x == other.x + 1; 
		}
		
		public function equals (other:BoardCoordinates) :Boolean
		{
			return this.x == other.x && this.y == other.y;
		} 
		
		public function get vicinity () :Vicinity 
		{
			return Vicinity.fromCoordinates(this);
		}
		
		public function writeToArray(array:ByteArray) :ByteArray
		{
			array.writeInt(x);
			array.writeInt(y);
			return array;
		}
				
		public static function readFromArray(array:ByteArray) :BoardCoordinates
		{
			return new BoardCoordinates(array.readInt(), array.readInt());
		}
		
		public static const VICINITY_SCALE:int = 4;
	}
}