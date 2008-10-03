package paths
{
	public interface PathFollower
	{
		function moveSideways (newCell:Cell) :void

		function climb (newCell:Cell) :void
	}
}