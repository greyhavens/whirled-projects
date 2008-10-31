package items.oilcan
{
	import arithmetic.BoardIterator;
	import arithmetic.CellIterator;
	import arithmetic.Vector;
	
	import interactions.Oilable;
	
	import items.ItemBase;
	import items.ItemCodes;
	import items.ItemPlayer;
	
    import world.Cell;

	public class OilCan extends ItemBase
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
			Log.debug ("checking whether "+player+" can use oil");
			return (player.cell is Oilable);
		}
		
		override public function useBy (player:ItemPlayer) :void
		{			
			const target:Cell = player.cell;
			Log.debug ("applying oil to "+target);
			
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
				Log.debug ("replacing "+cell);
				player.replace((toReplace as Oilable).oiled());
				cell = player.cellAt(iterator.next());		
			} while (cell.adjacentPartOf(toReplace));
		}
				
		override public function get code () :int
		{
			return ItemCodes.OIL_CAN;
		}

		override public function toString() :String
		{
			return "an oilcan";
		}		
	}
}