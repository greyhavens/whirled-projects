package cells.ladder
{
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;
	
	import cells.PlayerCellSprite;
	
	public class LadderView extends PlayerCellSprite
	{
		public function LadderView (cell:Cell, asset:Class)
		{
			super(cell, asset);
		}
		
		/** 
		 * When labelling the base, we want to point at the base of the ladder, not the side
		 * of the cell.
		 */
		override public function anchorPoint (direction:Vector) :GraphicCoordinates
		{			
			return super.anchorPoint(direction);
		}
	}
}