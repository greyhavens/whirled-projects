package arithmetic
{
	public class BoardPath
	{
		public function BoardPath(start:BoardCoordinates, finish:BoardCoordinates)
		{
			_iterator = new BoardIterator(start, start.distanceTo(finish).normalize());
			_finish = finish;
			_done = false;
		}
		
		public function next() :BoardCoordinates
		{
			if (!_done) {
				const current:BoardCoordinates = _iterator.next();
				if (current.equals(_finish)) {
					_done = true;
				}
				return current;
			}
			return null;
		}
		
		public function hasNext() :Boolean
		{
			return ! _done;
		}

		public function get delta () :Vector
		{
			return _iterator.delta;
		}

		protected var _done:Boolean;
		protected var _iterator:BoardIterator;		
		protected var _finish:BoardCoordinates;
	}
}