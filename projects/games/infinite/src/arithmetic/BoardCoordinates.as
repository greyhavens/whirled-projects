package arithmetic
{		
	public class BoardCoordinates extends Coordinates
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
	}
}