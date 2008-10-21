package items.teleporter
{
	import items.ItemBase;
	import items.ItemCodes;
	import items.ItemPlayer;
	
	public class Teleporter extends ItemBase
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

		override public function toString() :String
		{
			return "a teleporter";
		}
		
		override public function get code () :int 
		{
			return ItemCodes.TELEPORTER;
		}		
	}
}