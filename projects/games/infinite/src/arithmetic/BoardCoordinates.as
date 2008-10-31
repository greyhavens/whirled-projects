package arithmetic
{
	import flash.utils.ByteArray;
	
	import server.Messages.Serializable;
			
	public class BoardCoordinates extends Coordinates implements Serializable
	{
		public function BoardCoordinates(x:int, y:int)
		{ 
			super(x, y);
		}
		
		public override function toString () :String
		{
			return "board "+super.toString();
		}
		
		public function distanceTo (other:BoardCoordinates) :Vector
		{
			return new Vector(
				other._x - _x,
				other._y - _y
			);
		}

		public function translatedBy (v:Vector) :BoardCoordinates
		{
			return new BoardCoordinates(
				_x + v.dx,
				_y + v.dy
			)
		}
		
		public function graphicsCoordinates (
			boardOrigin:BoardCoordinates, graphicsOrigin:GraphicCoordinates) :GraphicCoordinates
		{
			return graphicsOrigin.translatedBy(boardOrigin.distanceTo(this).multiplyByVector(Config.cellSize));
		}
		
		public function above (other:BoardCoordinates) :Boolean
		{
			return this._x == other._x && this._y == other._y - 1; 
		}

		public function below (other:BoardCoordinates) :Boolean
		{
			return this._x == other._x && this._y == other._y + 1; 
		}
		
		public function onLeftOf (other:BoardCoordinates) :Boolean
		{
			return this._y == other._y && this._x == other._x - 1; 
		}
			
		public function onRightOf (other:BoardCoordinates) :Boolean
		{
			return this._y == other._y && this._x == other._x + 1; 
		}
		
		public function equals (other:BoardCoordinates) :Boolean
		{
			return this._x == other._x && this._y == other._y;
		} 
		
		public function get vicinity () :Vicinity 
		{
			return new Vicinity(this);
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