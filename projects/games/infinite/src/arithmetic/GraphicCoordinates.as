package arithmetic
{
	import flash.display.DisplayObject;
	
	public class GraphicCoordinates extends Coordinates
	{
		public function GraphicCoordinates(x:int, y:int)
		{
			super(x, y);
		}

		public static function fromDisplayObject(object:DisplayObject) :GraphicCoordinates
		{
			return new GraphicCoordinates (
				object.x,
				object.y
			);
		}

		public function applyTo (object:DisplayObject) :void 
		{
			object.x = x;
			object.y = y;
		}
		
		public function translatedBy (v:Vector) :GraphicCoordinates
		{
			return new GraphicCoordinates (
				_x + v.dx,
				_y + v.dy
			);
		}
		
		public function distanceTo (other:GraphicCoordinates) :Vector
		{
			return new Vector(
				other._x - _x,
				other._y - _y
			);
		}
		
		public function boardCoordinates 
			(boardOrigin:BoardCoordinates, graphicsOrigin:GraphicCoordinates) :BoardCoordinates
		{
			return boardOrigin.translatedBy(
				graphicsOrigin.distanceTo(this).divideByVector(CellBase.UNIT)
			);			
		}
		
		override public function toString () :String
		{
			return "graphic "+super.toString();
		}
		
		public static const ORIGIN:GraphicCoordinates = new GraphicCoordinates(0, 0);	
	}
}