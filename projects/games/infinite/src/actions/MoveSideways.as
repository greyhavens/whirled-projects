package actions
{
	import client.Objective;
	import flash.display.DisplayObject;
	
	public class MoveSideways extends Movement implements PlayerAction 
	{
		public function MoveSideways(
			player:PlayerCharacter, objective:Objective, targetCell:Cell)
		{		
			super(player, objective, targetCell);							
		}
	}
}