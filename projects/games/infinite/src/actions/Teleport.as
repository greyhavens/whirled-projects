package actions
{
	import arithmetic.BoardCoordinates;
	import arithmetic.Vector;
    import client.Objective;
	
	public class Teleport implements PlayerAction
	{
		public function Teleport(player:MoveInteractions, objective:Objective)
		{
			const jump:Vector = new Vector(-5 + (10 *Math.random()), -10 - (5 * Math.random()));
			_target = objective.cellAt(player.cell.position.translatedBy(jump));
			_player = player;   
			_objective = objective;
		}

		public function handleFrameEvent(event:FrameEvent):void
		{
			_player.actionComplete();				
			_player.arriveInCell(_target);
			_objective.scrollViewPointToPlayer();
		}
		
		protected var _player:MoveInteractions;
		protected var _objective:Objective;
		protected var _target:Cell;
	}
}