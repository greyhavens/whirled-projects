package cells.debug
{
	import sprites.CellSprite;
    import world.Cell;

	public class DebugView extends CellSprite
	{
		public function DebugView(cell:Cell)
		{
			super(cell, debugWall);
		}
		
        [Embed(source="../../../rsrc/png/debug-wall.png")]
        public static const debugWall:Class;        
	}
}