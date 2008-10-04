package paths
{
	import arithmetic.BoardCoordinates;
	
	public class SidewaysPath extends Path
	{
		public function SidewaysPath(start:BoardCoordinates, finish:BoardCoordinates)
		{
			super(start, finish);
		}		
		
		override public function applyTo(moveable:PathFollower) :void
		{
			moveable.moveSideways(finish);
		}
	}
}