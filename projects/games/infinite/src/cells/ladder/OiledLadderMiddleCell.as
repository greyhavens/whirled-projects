package cells.ladder
{
	import cells.CellCodes;
	
	import server.Messages.CellState;
	
	/** 
	 * An oiled ladder cell looks similar to a regular ladder, except that it causes the player to 
	 * fall on contact.
	 */
	public class OiledLadderMiddleCell extends LadderMiddleCell
	{
		public function OiledLadderMiddleCell(owner:Owner, state:CellState) :void
		{
			super(owner, state.position);
		}
		
		override public function get code () :int
		{
			return CellCodes.OILED_LADDER_MIDDLE;
		}
		
		override public function get type () :String 
		{ 
			return "oiled ladder middle";
		}
		
		/**
		 * An oily ladder cannot be gripped
		 */
		override public function get grip () :Boolean
		{			
			return ! isAboveGroundLevel();
		}
	}
}