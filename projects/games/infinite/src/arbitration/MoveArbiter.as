package arbitration
{
	public interface MoveArbiter
	{
		function proposeMove (player:MovableCharacter, destination:Cell) :void 		
	}
}