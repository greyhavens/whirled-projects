package paths
{
	public class ClimbingPath extends Path
	{
		public function ClimbingPath(start:Cell, finish:Cell)
		{
			super(start, finish);
		}

		override public function applyTo(moveable:PathFollower):void
		{
			moveable.climb(finish);
		}		
	}
}