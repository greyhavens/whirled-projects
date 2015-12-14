package cells.debug
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellCodes;
	
	public class DebugGroundCell extends DebugCell
	{
		public function DebugGroundCell(position:BoardCoordinates)
		{
			super(position);
		}

        override public function get code () :int
        {
        	return CellCodes.DEBUG_GROUND;
        }
				
		override public function toString () :String
		{
			return "Ground cell at "+position;
		}
	}
}