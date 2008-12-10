package world
{
	import arithmetic.BoardCoordinates;
	import arithmetic.Vicinity;
	
	import cells.NeighborhoodMemory;
	
	import server.Messages.CellUpdate;
	import server.Messages.Neighborhood;
	
	import world.board.Board;
	import world.board.BoardInteractions;
	
	public class NeighborhoodBoard implements Board, BoardInteractions
    {
        public function NeighborhoodBoard(starting:Board)
        {
            _starting = starting;
            _changed = new NeighborhoodMemory();           
		}
		
		public function cellAt (position:BoardCoordinates) :Cell
		{
			const found:Cell = _changed.recall(position);
			if (found != null) {
				return found;
			}
			return _starting.cellAt(position);
		}
		
		public function get startingPosition () :BoardCoordinates
		{
			return _starting.startingPosition;
		}
		
		public function replace (cell:Cell) :void
		{
			//Log.debug("new cell: "+cell);
			_changed.remember(cell);
		}
		
		public function neighborhood (hood:Neighborhood) :CellUpdate
		{
			//Log.debug("creating cell update for "+hood);
			const update:CellUpdate = new CellUpdate(levelNumber);
			for each (var vicinity:Vicinity in hood.vicinities) {
				//Log.debug("checking vicinity "+vicinity);
				update.addCells(_changed.inVicinity(vicinity));
			}
			return update;
		}
		
		public function get levelNumber () :int
		{
			return _starting.levelNumber;
		}
		
		protected var _starting:Board;
		protected var _changed:NeighborhoodMemory;
	}
}