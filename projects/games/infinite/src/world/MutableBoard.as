package world
{
	import arithmetic.BoardCoordinates;
	
	import cells.CellDictionary;
	import cells.CellMemory;
	
	import world.board.Board;
	import world.board.BoardInteractions;
	
	public class MutableBoard implements Board, BoardInteractions
	{
		public function MutableBoard(starting:Board)
		{
			_starting = starting;
			_changed = new CellDictionary();			
		}		
		
		public function cellAt (position:BoardCoordinates) :Cell
		{
			var found:Cell = _changed.recall(position);
			if (found == null) {
				return _starting.cellAt(position);
			}
			return found;
		}
		
		public function get startingPosition () :BoardCoordinates
		{
			return _starting.startingPosition;
		}
		
        public function replace (newCell:Cell) :void
        {
        	_changed.remember(newCell);
        }
		
        protected var _starting:Board;
        protected var _changed:CellMemory;
	}
}