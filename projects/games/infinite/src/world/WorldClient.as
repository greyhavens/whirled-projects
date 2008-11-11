package world
{
	import server.Messages.CellUpdate;
	import server.Messages.LevelUpdate;
	import server.Messages.PathStart;
	import server.Messages.PlayerPosition;
	
	public interface WorldClient extends Chronometer
	{
		/**
		 * A player entered a level.
		 */
        function updatePosition (detail:PlayerPosition) :void;
        
        function startPath (detail:PathStart) :void;	
        
        function levelUpdate (detail:LevelUpdate) :void;
        
        function updatedCells (detail:CellUpdate) :void;
        
        function timeSync (serverTime:Number) :void;      
 	}
}