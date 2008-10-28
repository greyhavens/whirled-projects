package world
{
	import server.Messages.LevelEntered;
	import server.Messages.PathStart;
	
	public interface WorldClient
	{
		/**
		 * A player entered a level.
		 */
        function levelEntered (detail:LevelEntered) :void;
        
        function startPath (detail:PathStart) :void;	
	}
}