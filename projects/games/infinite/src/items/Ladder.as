package items
{
	import arithmetic.BoardCoordinates;
	import arithmetic.BoardPath;
	import arithmetic.Vector;
	
	import cells.ladder.*;
	
	import sprites.*;
	
	/**
	 * This a ladder object.
	 */
	public class Ladder extends SimpleItem
	{
		/**
		 * Create a ladder with the specified number of segments.  All ladders have a base
		 * and a top allowing the player to use them to traverse at least one cell boundary
		 * but ladders may have multiple mid-sections allowing them to rise skywards.
		 */
		public function Ladder(segments:int)
		{
			_segments = segments;
		}
		
		override public function toString () :String
		{
			return "a ladder";
		}
				
		override public function get initialAsset () :Class
		{
			return ladderIcon;
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
					trace (c + " is not replacable so can't apply "+this);
					return false;
				}
			}
			
			return true;			
		}
		
		override public function useBy (player:ItemPlayer) :void
		{			
			const target:Cell = player.cell;
			player.replace(target.position, new LadderBaseCell(player, target.position));
			var j:int;
			for (j = 1; j <= _segments; j++) {
				var pos:BoardCoordinates = target.position.translatedBy(new Vector(0, -j));				
				player.replace(pos, new LadderMiddleCell(player, pos));
			}
			const top:BoardCoordinates = 
				target.position.translatedBy(new Vector(0, -(_segments + 1))); 
			player.replace(top, new LadderTopCell(player, top));
		}
				
		protected var _segments:int;
		
		[Embed(source="../../rsrc/png/ladder-icon.png")]
		protected static const ladderIcon:Class;
	}
}