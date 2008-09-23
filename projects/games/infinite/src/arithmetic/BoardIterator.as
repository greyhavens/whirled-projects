package arithmetic
{
	/**
	 * Iterator that will traverse through points on the board in the direction of the delta.
	 * Possibly this should be called a 'generator' since it has no end.  The first value returned
	 * is the start position.
	 */
	public class BoardIterator
	{		
		public var delta:Vector;
		
		public function BoardIterator(start:BoardCoordinates, delta:Vector)
		{
			this.delta = delta;
			_current = start;
		}
		
		public function next() :BoardCoordinates
		{
			const coordinates:BoardCoordinates = _current;
			_current = _current.translatedBy(delta);
			return coordinates;
		}

		protected var _current:BoardCoordinates;
	}
}