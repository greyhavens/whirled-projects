package arithmetic
{
	public class VoidBoardRectangle extends BoardRectangle
	{
		public function VoidBoardRectangle()
		{
			super(0,0,0,0);
		}
		
		/**
		 * The void rectangle contains no cells.  This is a premature optimization which reinforces
		 * the semantics, since any board rectangle with 0 area will work properly anyway.
		 */
		override public function contains (point:BoardCoordinates) :Boolean
		{
			return false;
		}
	}
}