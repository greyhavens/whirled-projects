package arithmetic
{
	import flash.display.DisplayObject;
	
	public class Vector
	{
		public var dx:int;
		public var dy:int;
		
		public function Vector(dx:int, dy:int) :void
		{
			this.dx = dx;
			this.dy = dy;
		}
		
		public function add(other:Vector) :Vector
		{
			return new Vector(
				dx + other.dx,
				dy + other.dy
			);
		}
		

		public function multiplyByVector(unit:Vector) :Vector
		{
			return new Vector(
				dx * unit.dx,
				dy * unit.dy
			);
		}
		
		public function multiplyByScalar(scalar:int) :Vector
		{
			return new Vector(
				dx * scalar,
				dy * scalar
			);
		}
		
		public function divideByScalar (scalar:int) :FloatVector
		{
			return new FloatVector(
				dx / scalar,
				dy / scalar
			);
		}
		
		public function divideByVector(unit:Vector) :Vector
		{
			return new Vector(
				dx / unit.dx,
				dy / unit.dy
			);
		}
		
		/**
		 * Return the pythagorean length of this vector.
		 */
		public function length () :int 
		{
			if (dx == 0) {
				return Math.abs(dy);
			} 
			
			if (dy == 0) {
				return Math.abs(dx);	
			}
			
			return Math.sqrt((dx * dx) + (dy * dy));
		}
		
		/**
		 * Normalize this vector.  Currently only works for vectors that have 0 for one of their 
		 * components.
		 */
		public function normalize () :Vector
		{
			if (dx == 0) {
				return new Vector(0, dy / Math.abs(dy))				
			}
			
			if (dy == 0) {
				return new Vector(dx / Math.abs(dx), 0);
			}
			
			throw new Error("can only normalize vectors that are orthogonal to the axes");
		}
		
		public function moveDisplayObject (object:DisplayObject) :void
		{
			object.x += dx;
			object.y += dy;
		}
		
		public function toString () :String
		{
			return "[dx="+dx+", dy="+dy+"]";
		}
		
		// Some useful directions that we use often.
		public static const UP:Vector = new Vector(0, -1);
		public static const DOWN:Vector = new Vector(0, 1);
		public static const LEFT:Vector = new Vector(-1, 0);
		public static const RIGHT:Vector = new Vector(1, 0);
		
		// The vector identity goes nowhere.
		public static const IDENTITY:Vector = new Vector(0, 0);	
	}
}