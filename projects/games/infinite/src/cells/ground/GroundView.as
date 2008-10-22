package cells.ground
{
	import sprites.CellSprite;
    import world.Cell;

	public class GroundView extends CellSprite
	{
		public function GroundView(cell:Cell)
		{
			super(cell, ledgeGroundCell);
		}
		
		[Embed(source="../../../rsrc/png/ledge-ground-cell.png")]
		public static const ledgeGroundCell:Class; 		
	}
}
