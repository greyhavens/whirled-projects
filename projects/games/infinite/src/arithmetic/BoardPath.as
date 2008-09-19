package arithmetic
{
	public class BoardPath
	{
		public function BoardPath(start:BoardCoordinates, finish:BoardCoordinates)
		{
			_iterator = new BoardIterator(start, start.distanceTo(finish).normalize());
			_finish = finish;
		}
		
		public function next() :BoardCoordinates
		{
			if (_iterator != null) {
				const current:BoardCoordinates = _iterator.next();
				if (current.equals(_finish)) {
					_iterator = null;
				}
				return current;
			}
			return null;
		}
		
		public function hasNext() :Boolean
		{
			return _iterator != null;
		}

		protected var _iterator:BoardIterator;		
		protected var _finish:BoardCoordinates;
	}
}