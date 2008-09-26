package items
{
	public class Teleporter extends SimpleItem
	{
		public function Teleporter()
		{
			super();
		}

		/**
		 * A teleporter can be used at any time.
		 */
		override public function isUsableBy (player:ItemPlayer) :Boolean
		{
			return true;
		}
		
		override public function useBy (player:ItemPlayer) :void
		{
			player.teleport();
		}

		override public function get initialAsset () :Class
		{
			return teleportIcon;
		}

		override public function toString() :String
		{
			return "a teleporter";
		}
		
		[Embed(source="png/teleport-icon.png")]
		protected static const teleportIcon:Class;			
		
	}
}