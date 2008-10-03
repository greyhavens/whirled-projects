package paths
{
	import arithmetic.VoidBoardRectangle;
	
	public class Path
	{
		public var start:Cell;
		public var finish:Cell;
		
		public function Path(start:Cell, finish:Cell)
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