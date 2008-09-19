package arithmetic
{
	public class FloatVector
	{
		public function FloatVector(dx:Number, dy:Number)		
		{
			this.dx = dx;
			this.dy = dy;
		}
		
		public function multiplyByScalar (scalar:int) :FloatVector
		{
			return new FloatVector( 
				dx * scalar,
				dy * scalar
			)
		}		

		public function toVector () :Vector
		{
			return new Vector(dx, dy);
		}

		public function toString() :String
		{
			return "["+dx+", "+dy+"]";	
		}
				 		
		protected var dx:Number;
		protected var dy:Number;
	}
}