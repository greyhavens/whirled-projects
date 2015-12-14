package cells.ladder
{
	import sprites.CellSprite;
    import world.Cell;

	public class LadderTopView extends LadderView
	{
		public function LadderTopView(cell:Cell)
		{
			super(cell, ladderTop);
		}

		[Embed(source="../../../rsrc/png/ladder-top.png")]
		public static const ladderTop:Class;		
	}
}
