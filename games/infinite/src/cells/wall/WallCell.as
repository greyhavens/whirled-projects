package cells.wall
{
	import arithmetic.*;
	
	import cells.CellCodes;
	import cells.CellUtil;
	
	import interactions.Oilable;
	
	import world.Cell;
	
	public class WallCell extends WallBaseCell implements Oilable
	{
		public function WallCell(position:BoardCoordinates)
		{
			super(position);
		}
	
		public function oiledBy (saboteur:Owner) :Cell
		{
			return new OiledWallCell(CellUtil.sabotagedState(this, saboteur));
		}
	
		override public function get code () :int
		{
			return CellCodes.WALL;
		}
	
		override public function get type () :String { return "wall"; }	
	}
}