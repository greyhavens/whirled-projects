package cells
{
	import arithmetic.BoardCoordinates;
	
	/** 
	 * An oiled ladder cell looks similar to a regular ladder, except that it causes the player to 
	 * fall on contact.
	 */
	public class OiledLadderCell extends LadderCell
	{
		public function OiledLadderCell(owner:Owner, position:BoardCoordinates, type:int) :void
		{
			super(owner, position, type);
		}
		
		override public function get type () :String 
		{ 
			switch (_part) {
				case BASE: return "oiled ladder base";
				case MIDDLE: return "oiled ladder middle";
				case TOP: return "oiled ladder top";
			}
			return "unknown oiled ladder section";	
		}	
		
		override protected function get initialAsset() :Class
		{
			switch (_part) {
				case BASE: return oiledLadderBase;
				default: return super.initialAsset;
			}
		}
		
		/**
		 * An oily ladder cannot be gripped
		 */
		override public function get grip () :Boolean
		{			
			return ! isAboveGroundLevel();
		}
		
		[Embed(source="../../rsrc/png/ladder-base-oiled.png")]
		public static const oiledLadderBase:Class;	

	}
}