package arithmetic
{
	
	import flash.display.DisplayObject;
	
	public class GraphicCoordinates extends Coordinates
	{
		public function GraphicCoordinates(x:int, y:int)
		{
			super(x, y);
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
				graphicsOrigin.distanceTo(this).divideByVector(Config.cellSize)
			);			
		}

		/**
		 * Return the coordinate system in which this point corresponds with the one provided.
		 */
		public function correspondsTo (other:GraphicCoordinates) :CoordinateSystem
		{
			return new CoordinateSystem(this, other);
		}
		
		/**
		 * Convert this point into a coordinate within the supplied system.
		 */
		public function from (system:CoordinateSystem) :GraphicCoordinates
		{
			return system.toLocal(this);
		}
		
		override public function toString () :String
		{
			return "graphic "+super.toString();
		}
		
		public static const ORIGIN:GraphicCoordinates = new GraphicCoordinates(0, 0);	
	}
}