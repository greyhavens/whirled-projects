package items.ladder
{
	import flash.events.MouseEvent;
	
	import graphics.NumericBadge;
	
	import items.Item;
	
	import sprites.ItemSprite;
	
	public class LadderView extends ItemSprite
	{
		public function LadderView(item:Item)
		{
			super(ladderIcon);
			badge = new NumericBadge(item.attributes.segments + 2);
			badge.addEventListener(MouseEvent.CLICK, dispatchEvent);
			addChild(badge);
		}

        protected var badge:NumericBadge;

        [Embed(source="../../../rsrc/png/ladder-icon.png")]
        protected static const ladderIcon:Class;        
	}
}