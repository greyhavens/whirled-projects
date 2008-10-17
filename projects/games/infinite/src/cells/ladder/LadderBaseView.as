package cells.ladder
{
	import arithmetic.Geometry;
	import arithmetic.GraphicCoordinates;
	import arithmetic.Vector;

	public class LadderBaseView extends LadderView
	{
		public function LadderBaseView(cell:Cell)
		{
			super(cell, ladderAsset);
		}

		/** 
		 * When labelling the base, we want to point at the base of the ladder, not the side
		 * of the cell.
		 */
		override public function anchorPoint (direction:Vector) :GraphicCoordinates
		{			
			return new GraphicCoordinates(
			 	super.anchorPoint(direction).x,
			 	Geometry.coordsOf(this).translatedBy(FIRSTRUNG).y
			 );
		}
		
		protected function get ladderAsset () :Class
		{
			return ladderBase;
		}

		[Embed(source="../../../rsrc/png/ladder-base.png")]
		public static const ladderBase:Class;
		
		// The ladder is this percentage of the way down the cell.
		public static const FIRSTRUNG:Vector = 
			Vector.DOWN.multiplyByVector(Config.cellSize).multiplyByScalar(0.1);
	}
}
