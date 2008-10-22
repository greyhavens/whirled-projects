package actions
{
	import client.Objective;
    import world.Cell;
	
	public class Climb extends Movement implements PlayerAction
	{
		public function Climb (
			player:PlayerCharacter, objective:Objective, targetCell:Cell) :void
		{		
			super(player, objective, targetCell);
		}
	}
}