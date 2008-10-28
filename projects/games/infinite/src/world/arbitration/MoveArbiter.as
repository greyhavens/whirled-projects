package world.arbitration
{	
    import world.Cell;
    import world.Player;
	
	public interface MoveArbiter
	{
		function proposeMove (player:Player, destination:Cell) :void 		
	}
}