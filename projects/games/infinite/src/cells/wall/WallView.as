package cells.wall
{
	import sprites.CellSprite;

	public class WallView extends CellSprite
	{
		public function WallView(cell:Cell)
		{
			super(cell, wall);
		}

		[Embed(source="../../../rsrc/png/wall.png")]
		public static const wall:Class;		
	}
}