package arithmetic
{
	public class BoardIterator
	{
		public function BoardIterator(start:BoardCoordinates, delta:Vector)
		{
			_delta = delta;
			_current = start;
		}
		
		public function next() :BoardCoordinates
		{
			const coordinates:BoardCoordinates = _current;
			_current = _current.translatedBy(_delta);
			return coordinates;
		}

		protected var _current:BoardCoordinates;
		protected var _delta:Vector;
	}
}