package cells.ladder
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellCodes;
	
	/** 
	 * An oiled ladder cell looks similar to a regular ladder, except that it causes the player to 
	 * fall on contact.
	 */
	public class OiledLadderBaseCell extends LadderBaseCell
	{
		public function OiledLadderBaseCell(owner:Owner, position:BoardCoordinates) :void
		{
			super(owner, position);
		}
		
		override public function get code () :int
		{
			return CellCodes.OILED_LADDER_BASE;
		}
		
		override public function get type () :String 
		{ 
			return "oiled ladder base";
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