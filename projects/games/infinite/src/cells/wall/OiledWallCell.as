package cells.wall
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellCodes;

	public class OiledWallCell extends WallCell
	{
		public function OiledWallCell(position:BoardCoordinates)
		{
			super(position);
		}
		
		override public function get code () :int
		{
			return CellCodes.OILED_WALL;
		}
		
		override public function get grip () :Boolean
		{
			return false;
		}		
		
		override public function get type () :String { return "oiled wall"; }			
	}
}