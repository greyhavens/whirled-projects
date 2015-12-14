package arithmetic
{
    import world.Cell;
    import world.board.*;
	
	public class CellIterator
	{
		public function CellIterator(start:Cell, board:BoardAccess, delta:Vector)
		{
			_board = board;
			_delta = delta;
			_current = start;
		}
		
		public function next() :Cell
		{
			_current = _board.cellAt(_current.position.translatedBy(_delta));
			return _current;
		}

		protected var _current:Cell;
		protected var _delta:Vector;
		protected var _board:BoardAccess;
	}
}