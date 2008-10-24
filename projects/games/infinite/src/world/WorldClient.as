package world
{
	import server.Messages.LevelEntered;
	
	public interface WorldClient
	{
		/**
		 * A player entered a level.
		 */
        function levelEntered(detail:LevelEntered) :void;		
	}
}