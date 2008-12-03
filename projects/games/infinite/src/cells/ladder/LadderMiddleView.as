package cells.ladder
{
	import sprites.CellSprite;
    import world.Cell;
    import world.Cell;

	public class LadderMiddleView extends LadderView
	{
		public function LadderMiddleView(cell:Cell)
		{
			super(cell, ladderMiddle);
		}

		[Embed(source="../../../rsrc/png/ladder-middle.png")]		
		public static const ladderMiddle:Class;	
	}
}
