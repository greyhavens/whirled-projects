package items.ladder
{
	import items.Item;
	
	import sprites.ItemSprite;
	
	public class LadderView extends ItemSprite
	{
		public function LadderView(item:Item)
		{
			super(ladderIcon);
		}

        [Embed(source="../../../rsrc/png/ladder-icon.png")]
        protected static const ladderIcon:Class;
	}
}