package items
{
	import arithmetic.BoardIterator;
	import arithmetic.CellIterator;
	import arithmetic.Vector;
	
	import interactions.Oilable;
	

	public class OilCan extends SimpleItem
	{
		public function OilCan()
		{
			super();
		}
				
		/**
		 * The oilcan can apply to a ladder.
		 */
		override public function isUsableBy (player:ItemPlayer) :Boolean
		{
			trace ("checking whether "+player+" can use oil");
			return (player.cell is Oilable); 
		}
		
		override public function useBy (player:ItemPlayer) :void
		{			
			const target:Cell = player.cell;
			trace ("applying oil to "+target);
			
			// find the bottom of the object
			var bottom:Cell = player.cell;
			const search:CellIterator = bottom.iterator(player, Vector.DOWN);
			do {
				var test:Cell = search.next();
				if (! test.adjacentPartOf(bottom)) {
					break;
				}
				bottom = test;
			} while (true)
			
			// now oil up the object
			const iterator:BoardIterator = new BoardIterator(bottom.position, Vector.UP);
			var cell:Cell = player.cellAt(iterator.next());
			do {
				var toReplace:Cell = cell;
				trace ("replacing "+cell);
				player.replace(toReplace.position, (toReplace as Oilable).oiled());
				cell = player.cellAt(iterator.next());		
			} while (cell.adjacentPartOf(toReplace));
		}
		
		override public function get initialAsset () :Class
		{
			return oilcanIcon;
		}

		override public function toString() :String
		{
			return "an oilcan";
		}
		
		[Embed(source="png/oilcan-icon.png")]
		protected static const oilcanIcon:Class;			
	}
}