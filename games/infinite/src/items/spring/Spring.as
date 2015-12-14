package items.spring
{
	import items.ItemBase;
	import items.ItemCodes;
	
	public class Spring extends ItemBase
	{
		public function Spring()
		{
			super();
		}

        override public function get code () :int
        {
        	return ItemCodes.SPRING;
        }

		override public function toString() :String
		{
			return "a spring";
		}		
	}
}