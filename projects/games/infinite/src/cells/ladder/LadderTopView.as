package cells.ladder
{
	import sprites.CellSprite;

	public class LadderTopView extends CellSprite
	{
		public function LadderTopView(cell:Cell)
		{
			super(cell, ladderTop);
		}

		[Embed(source="../../../rsrc/png/ladder-top.png")]
		public static const ladderTop:Class;		
	}
}
