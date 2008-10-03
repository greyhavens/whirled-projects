package paths
{
	import arithmetic.VoidBoardRectangle;
	
	public class SidewaysPath extends Path
	{
		public function SidewaysPath(start:Cell, finish:Cell)
		{
			super(start, finish);
		}		
		
		override public function applyTo(moveable:PathFollower) :void
		{
			moveable.moveSideways(finish);
		}
	}
}