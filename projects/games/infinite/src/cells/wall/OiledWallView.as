package cells.wall
{
	import sprites.CellSprite;
	
	import world.Cell;

	public class OiledWallView extends CellSprite
	{
		public function OiledWallView(cell:Cell)
		{
			super(cell, oiledWall);
		}

		[Embed(source="../../../rsrc/png/wall-oiled.png")]
		public static const oiledWall:Class;			
	}
}