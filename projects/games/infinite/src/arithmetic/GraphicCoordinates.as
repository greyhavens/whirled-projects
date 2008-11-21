package arithmetic
{
	
	import flash.display.DisplayObject;
	
	public class GraphicCoordinates
	{
	    public var x:int;
	    public var y:int;
	    
		public function GraphicCoordinates(x:int, y:int)
		{
		    this.x = x;
		    this.y = y;
		}
		
		public function translatedBy (v:Vector) :GraphicCoordinates
		{
			return new GraphicCoordinates (
				x + v.dx,
				y + v.dy
			);
		}
		
		public function distanceTo (other:GraphicCoordinates) :Vector
		{
			return new Vector(
				other.x - x,
				other.y - y
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
		
		public function toString () :String
		{
			return "graphic ("+x+", "+y+")";
		}
		
		public static const ORIGIN:GraphicCoordinates = new GraphicCoordinates(0, 0);	
	}
}