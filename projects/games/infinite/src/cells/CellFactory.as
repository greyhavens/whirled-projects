package cells
{
	import arithmetic.BoardCoordinates;
	
	import world.Cell;
	
	public class CellFactory
	{
		public function CellFactory()
		{
		}
		
		public function makeCell (code:int, owner:Owner, position:BoardCoordinates) :Cell
		{
			switch (code) {
				case CellCodes.NONE:
				case CellCodes.WALL:
				case CellCodes.WALL_BASE:
				case CellCodes.OILED_WALL:
				case CellCodes.LADDER_BASE:
				case CellCodes.LADDER_MIDDLE:
				case CellCodes.LADDER_TOP:
				case CellCodes.FRUIT_MACHINE:
				case CellCodes.OILED_LADDER_BASE:
				case CellCodes.OILED_LADDER_MIDDLE:
				case CellCodes.OILED_LADDER_TOP:
				case CellCodes.GROUND:
				case CellCodes.DEBUG:
				case CellCodes.DEBUG_GROUND:
			}		
			throw new Error(this + " doesn't know how to construct a cell of type "+code);
		}
	}
}