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
		
		public function multiplyByScalar(scalar:Number) :Vector
		{
			return new Vector(
				dx * scalar,
				dy * scalar
			);
		}
				
		public function divideByScalar (scalar:int) :Vector
		{
			return new Vector(
				dx / scalar,
				dy / scalar
			);			
		}
		
		public function get half () :Vector
		{
			return divideByScalar(2);
		}
		
		public function divideByScalarF (scalar:int) :FloatVector
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
		public function get length () :Number 
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
		
		public function normalizeF () :FloatVector
		{
			if (dx == 0) {
				return new FloatVector(0, dy / Math.abs(dy))				
			}
			
			if (dy == 0) {
				return new FloatVector(dx / Math.abs(dx), 0);
			}
			
			return divideByScalarF(length);
		}
		
		/**
		 * Return only the x component of this vector.
		 */
		public function xComponent () :Vector
		{
			return new Vector(dx, 0);
		}

		/**
		 * Return only the y component of this vector.
		 */
		public function yComponent () :Vector
		{
			return new Vector(0, dy);
		}
		
		public function get reversed () :Vector
		{
			return new Vector(-dx, -dy);
		}
		
		public function moveDisplayObject (object:DisplayObject) :void
		{
			object.x += dx;
			object.y += dy;
		}
		
		/**
		 * Return the compass diagonal associated with this vector.
		 */
		public function asCompassDiagonal () :Vector
		{
			if (dx == 0) {
				if (dy < 0) return N;
				if (dy > 0) return S;
				return IDENTITY;
			}
			if (dy == 0) {
				if (dx < 0) return W;
				if (dx > 0) return E;
				return IDENTITY;
			}
			if (dy < 0) {
				if (dx < 0) return NW;
				if (dx > 0) return NE;
			}
			if (dy > 0) {
				if (dx < 0) return SW;
				if (dx > 0) return SE;
			}
			throw new Error("impossible error");
		}
		
		public function equals (other:Vector) :Boolean
		{
			return (dx == other.dx && dy == other.dy);
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

		public static const N:Vector = UP;
		public static const S:Vector = DOWN;
		public static const E:Vector = LEFT;
		public static const W:Vector = RIGHT;  
				
		public static const NW:Vector = new Vector(-1, -1);
		public static const NE:Vector = new Vector(1, -1);
		public static const SE:Vector = new Vector(1, 1);
		public static const SW:Vector = new Vector(-1, 1);
		
		// The vector identity goes nowhere.
		public static const IDENTITY:Vector = new Vector(0, 0);	
	}
}