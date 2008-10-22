package cells.debug
{
	import sprites.CellSprite;
    import world.Cell;

	public class DebugGroundView extends CellSprite
	{
		public function DebugGroundView(cell:Cell)
		{
			super(cell, debugGround);
		}
		
        [Embed(source="../../../rsrc/png/debug-ground.png")]
        public static const debugGround:Class;        
	}
}