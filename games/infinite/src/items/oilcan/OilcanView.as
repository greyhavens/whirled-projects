package items.oilcan
{
	import items.Item;
	
	import sprites.ItemSprite;
	
	public class OilcanView extends ItemSprite
	{
		public function OilcanView(item:Item)
		{
			super(oilcanIcon);
		}

        [Embed(source="../../../rsrc/png/oilcan-icon.png")]
        protected static const oilcanIcon:Class;            
	}
}