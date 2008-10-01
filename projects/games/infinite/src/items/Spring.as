package items
{
	public class Spring extends SimpleItem
	{
		public function Spring()
		{
			super();
		}

		override public function get initialAsset () :Class
		{
			return springIcon;
		}

		override public function toString() :String
		{
			return "a spring";
		}
		
		[Embed(source="../../rsrc/png/spring-icon.png")]
		protected static const springIcon:Class;		
	}
}