package cells.debug
{
	import sprites.CellSprite;

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