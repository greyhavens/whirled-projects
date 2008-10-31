package items.ladder
{
	import arithmetic.BoardCoordinates;
	import arithmetic.BoardPath;
	import arithmetic.Vector;
	
	import cells.ladder.*;
	
	import items.ItemBase;
	import items.ItemCodes;
	import items.ItemPlayer;
	
	import sprites.*;

    import world.Cell;
	
	/**
	 * This a ladder object.
	 */
	public class Ladder extends ItemBase
	{
		/**
		 * Create a ladder with the specified number of segments.  All ladders have a base
		 * and a top allowing the player to use them to traverse at least one cell boundary
		 * but ladders may have multiple mid-sections allowing them to rise skywards.
		 */
		public function Ladder(definition:Object)
		{
			_segments = definition.segments;
		}
		
		override public function toString () :String
		{
			return "a ladder";
		}
						
		override public function isUsableBy (player:ItemPlayer) :Boolean
		{
			const target:Cell = player.cell;
			const path:BoardPath = 
				new BoardPath(target.position, 
					target.position.translatedBy(new Vector(0, -(_segments+1))));
			
			while (path.hasNext()) {
				var c:Cell = player.cellAt(path.next());
				if (! c.replacable) {
					Log.debug (c + " is not replacable so can't apply "+this);
					return false;
				}
			}
			
			return true;			
		}
		
		override public function useBy (player:ItemPlayer) :void
		{			
			const target:Cell = player.cell;
			player.replace(new LadderBaseCell(player, target.position));
			var j:int;
			for (j = 1; j <= _segments; j++) {
				var pos:BoardCoordinates = target.position.translatedBy(new Vector(0, -j));				
				player.replace(new LadderMiddleCell(player, pos));
			}
			const top:BoardCoordinates = 
				target.position.translatedBy(new Vector(0, -(_segments + 1))); 
			player.replace(new LadderTopCell(player, top));
		}

        override public function get code () :int
        {
        	return ItemCodes.LADDER;
        }
				
		protected var _segments:int;		
	}
}