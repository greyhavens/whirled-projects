package cells.ladder
{
	import sprites.CellSprite;

	public class LadderMiddleView extends CellSprite
	{
		public function LadderMiddleView(cell:Cell)
		{
			super(cell, ladderMiddle);
		}

		[Embed(source="../../../rsrc/png/ladder-middle.png")]		
		public static const ladderMiddle:Class;	
	}
}
