package server.Messages
{
	import arithmetic.BoardCoordinates;
	
	public class LevelEntered
	{
		public var userId:int;
		public var level:int;
		public var position:BoardCoordinates; 
		
		public function LevelEntered(userId:int, level:int, position:BoardCoordinates)
		{
			this.userId = userId;
			this.level = level;
			this.position = position;
		}
	}
}
