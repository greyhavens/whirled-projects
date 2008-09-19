package
{
	import arithmetic.Vector;
	
	public class Slice
	{
		public var start:int;
		public var finish:int;
		
		public function Slice(start:int, finish:int)
		{
			this.start = start;
			this.finish = finish;
		}	

		/**
		 * Return true if the slice includes the specified point.
		 */
		public function contains (point:int) :Boolean
		{
			return point >= start && point <=finish;	
		}
		
		/**
		 * Return the direction one would have to move to get to the slice from the specified point.
		 * If the point is within the slice, then the identity vector is returned.
		 */
		public function directionFrom (point:int) :Vector
		{
			if (point > finish) 
			{
//				trace (point+" is greater than "+this+" so returning "+Vector.LEFT);
				return Vector.LEFT;
			}
			if (point < start) 
			{
//				trace (point+" is less than than "+this+" so returning "+Vector.RIGHT);
				return Vector.RIGHT;
			}
//			trace (point+" is within "+this+" so returning "+Vector.IDENTITY);
			return Vector.IDENTITY;
		}
		
		/**
		 * Return a new slice covering the same extent as the old one but extended to include the
		 * supplied point, or the same slice if it's already included.
		 */
		public function expandedToInclude (point:int) :Slice
		{
//			trace ("expanding "+this+" to include "+point);
			if (start > point) {
				return new Slice(point, finish);
			}
			
			if (finish < point) {
				return new Slice(start, point);
			}
			
			return this;
		}
		
		public function toString () :String
		{
			return "slice from "+start+" to "+finish
		}
	}
}