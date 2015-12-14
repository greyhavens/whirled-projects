package cells.ladder
{
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import sprites.CellSprite;
	
	import world.Cell;
	
	public class LadderView extends CellSprite
	{
		public function LadderView (cell:Cell, asset:Class)
		{
			super(cell, asset);
		}
				
		override public function get showLabel () :Boolean { return true; }
	}
}