package items.teleporter
{
	import items.Item;
	
	import sprites.ItemSprite;
	
	public class TeleporterView extends ItemSprite
	{
		public function TeleporterView(item:Item)
		{
			super(teleportIcon);
		}	
		
        [Embed(source="../../../rsrc/png/teleport-icon.png")]
        protected static const teleportIcon:Class;          		
	}
}