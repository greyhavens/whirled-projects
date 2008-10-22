package world.arbitration
{	
    import world.Cell;
	
	public interface MoveArbiter
	{
		function proposeMove (player:MovableCharacter, destination:Cell) :void 		
	}
}