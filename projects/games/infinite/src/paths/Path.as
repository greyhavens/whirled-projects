package paths
{
	import arithmetic.BoardCoordinates;
	
	import world.Player;
	
	public class Path
	{
		public var start:BoardCoordinates;
		public var finish:BoardCoordinates;
		
		public function Path(start:BoardCoordinates, finish:BoardCoordinates)
		{
			this.start = start;
			this.finish = finish;
		}
		
		public function applyTo(movable:PathFollower) :void
		{
			throw new Error("base path type can't actually be applied to a path follower");
		}		
	}
}