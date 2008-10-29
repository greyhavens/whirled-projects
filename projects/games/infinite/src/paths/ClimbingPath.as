package paths
{
	import arithmetic.BoardCoordinates;
	
	public class ClimbingPath extends Path
	{
		public function ClimbingPath(start:BoardCoordinates, finish:BoardCoordinates)
		{
			super(start, finish);
		}

		override public function applyTo(moveable:PathFollower):void
		{
			moveable.climb(finish);
		}		
		
		public function toString () :String
		{
			return "a climb to "+finish; 
		}
	}
}