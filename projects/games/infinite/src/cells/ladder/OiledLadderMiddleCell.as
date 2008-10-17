package cells.ladder
{
	import arithmetic.BoardCoordinates;
	
	/** 
	 * An oiled ladder cell looks similar to a regular ladder, except that it causes the player to 
	 * fall on contact.
	 */
	public class OiledLadderMiddleCell extends LadderMiddleCell
	{
		public function OiledLadderMiddleCell(owner:Owner, position:BoardCoordinates) :void
		{
			super(owner, position);
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