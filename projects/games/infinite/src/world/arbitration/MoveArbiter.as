package world.arbitration
{	
    import world.Cell;
    import world.Player;
	
	public interface MoveArbiter
	{
		function proposeMove (player:MovablePlayer, destination:Cell) :void 		
	}
}