package whirled
{
	import arithmetic.BoardCoordinates;
	
	public class MoveProposal
	{
		public var origin:BoardCoordinates;
		public var destination:BoardCoordinates
		
		public function MoveProposal (player:PlayerCharacter, destination:Cell) 
		{
			this.origin = player.cell.position;
			this.destination = destination.position;
		}		
	}	
}