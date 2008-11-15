package cells
{
	import cells.fruitmachine.FruitMachineCell;
	import cells.ladder.LadderBaseCell;
	import cells.ladder.LadderMiddleCell;
	import cells.ladder.LadderTopCell;
	import cells.ladder.OiledLadderBaseCell;
	import cells.ladder.OiledLadderMiddleCell;
	import cells.ladder.OiledLadderTopCell;
	import cells.wall.OiledWallCell;
	import cells.wall.WallBaseCell;
	import cells.wall.WallCell;
	
	import server.Messages.CellState;
	
	import world.Cell;
	
	public class CellFactory
	{
		public function CellFactory()
		{
		}
		
		public function makeCell (owner:Owner, state:CellState) :Cell
		{
			switch (state.code) {
				case CellCodes.WALL: return new WallCell(state.position);
				case CellCodes.WALL_BASE: return new WallBaseCell(state.position);
				case CellCodes.OILED_WALL: return new OiledWallCell(state.position);
				case CellCodes.LADDER_BASE: return new LadderBaseCell(owner, state.position);
				case CellCodes.LADDER_MIDDLE: return new LadderMiddleCell(owner, state.position);
				case CellCodes.LADDER_TOP: return new LadderTopCell(owner, state.position);
				case CellCodes.FRUIT_MACHINE: return new FruitMachineCell(state);
				case CellCodes.OILED_LADDER_BASE: return new OiledLadderBaseCell(owner, state.position);
				case CellCodes.OILED_LADDER_MIDDLE: return new OiledLadderMiddleCell(owner, state.position);
				case CellCodes.OILED_LADDER_TOP: return new OiledLadderTopCell(owner, state.position);
				case CellCodes.GROUND:
				case CellCodes.DEBUG:
				case CellCodes.DEBUG_GROUND:
			}		
			throw new Error(this + " doesn't know how to construct a cell of type "+state.code);
		}
	}
}