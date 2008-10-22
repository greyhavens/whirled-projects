package world
{
	import arithmetic.BoardPath;
	import arithmetic.Vector;
    import world.Cell;
    import world.BoardAccess;
	
	public class CellPath
	{
		public function CellPath(board:BoardAccess, start:Cell, finish:Cell)
		{
			_path = new BoardPath(start.position, finish.position);
			_board = board;
		}
		
		public function next() :Cell
		{
			return _board.cellAt(_path.next());
		}
		
		public function hasNext() :Boolean
		{
			return _path.hasNext();
		}

		public function delta () :Vector
		{
			return _path.delta;
		}

		protected var _board:BoardAccess;
		protected var _path:BoardPath;
	}
}