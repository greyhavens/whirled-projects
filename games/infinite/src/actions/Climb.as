package actions
{
	import client.Objective;
	import client.player.Player;
	
	import sprites.PlayerSprite;
	
	import world.Cell;
	
	public class Climb extends Movement implements PlayerAction
	{
		public function Climb (
			player:Player, sprite:PlayerSprite, objective:Objective, targetCell:Cell) :void
		{		
			super(player, sprite, objective, targetCell);
		}
		
		public function toString () :String
		{
			return "a climb to "+_targetCell
		}
	}
}