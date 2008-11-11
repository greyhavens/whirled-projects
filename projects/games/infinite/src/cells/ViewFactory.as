package cells
{
	import cells.debug.DebugGroundView;
	import cells.debug.DebugView;
	import cells.fruitmachine.*;
	import cells.ground.GroundView;
	import cells.ladder.*;
	import cells.views.*;
	import cells.wall.*;
	import world.Cell;
	
	/**
	 * The view factory is used by the objective to obtain a new view for a specific cell.  Thus the
	 * cells can be used on the server and client alike.
	 */
	public class ViewFactory
	{
		public function ViewFactory()
		{
		}
		
		public function viewOf(cell:Cell, time:Number) :CellView 
		{
			switch (cell.code) {
				case CellCodes.WALL: return new WallView(cell);
				case CellCodes.LADDER_BASE: return new LadderBaseView(cell);
				case CellCodes.LADDER_MIDDLE: return new LadderMiddleView(cell);
				case CellCodes.LADDER_TOP: return new LadderTopView(cell);
				case CellCodes.FRUIT_MACHINE: return new FruitMachineView(cell, time);
				case CellCodes.OILED_LADDER_BASE: return new OiledLadderBaseView(cell);
				case CellCodes.OILED_LADDER_MIDDLE: return new LadderMiddleView(cell);
				case CellCodes.OILED_LADDER_TOP: return new LadderTopView(cell);
				case CellCodes.WALL_BASE: return new WallBaseView(cell);
				case CellCodes.GROUND: return new GroundView(cell);
				case CellCodes.DEBUG: return new DebugView(cell);
				case CellCodes.DEBUG_GROUND: return new DebugGroundView(cell);
			}
			throw new Error("the viewfactory doesn't know how to construct a view for "+cell);
		}		
	}
}