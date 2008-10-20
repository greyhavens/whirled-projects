package cells.wall
{
	import sprites.CellSprite;

	public class WallBaseView extends CellSprite
	{
		public function WallBaseView(cell:Cell)
		{
			super(cell, wall);
		}

		[Embed(source="../../../rsrc/png/wall.png")]
		public static const wall:Class;		
	}
}