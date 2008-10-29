package actions
{
	import client.Objective;
	import client.player.Player;
	
	import sprites.PlayerSprite;
	
	import world.Cell;
	
	public class MoveSideways extends Movement implements PlayerAction 
	{
		public function MoveSideways(
			player:Player, view:PlayerSprite, objective:Objective, targetCell:Cell)
		{		
			super(player, view, objective, targetCell);							
		}
	}
}