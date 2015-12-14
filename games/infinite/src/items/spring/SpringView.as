package items.spring
{
	import items.Item;
	
	import sprites.ItemSprite;
	
	public class SpringView extends ItemSprite
	{
		public function SpringView(item:Item)
		{
			super(springIcon);
		}

        [Embed(source="../../../rsrc/png/spring-icon.png")]
        protected static const springIcon:Class;       
	}
}