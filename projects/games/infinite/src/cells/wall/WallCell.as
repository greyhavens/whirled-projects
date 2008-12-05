package cells.wall
{
	import arithmetic.*;
	
	import cells.CellCodes;
	
	import interactions.Oilable;
    import world.Cell;
	
	public class WallCell extends WallBaseCell implements Oilable
	{
		public function WallCell(position:BoardCoordinates)
		{
			super(position);
		}
	
		public function oiledBy (owner:Owner) :Cell
		{
			return new OiledWallCell(_position);
		}
	
		override public function get code () :int
		{
			return CellCodes.WALL;
		}
	
		override public function get type () :String { return "wall"; }	
	}
}