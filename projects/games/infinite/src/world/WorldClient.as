package world
{
	import server.Messages.CellState;
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
        
        /**
         * The client should start a player moving along a path.
         */ 
        function startPath (detail:PathStart) :void;	
        
        /**
         * New information about the players on a level is available.
         */ 
        function levelUpdate (detail:LevelUpdate) :void;
        
        /**
         * The client should handle a series of updated cells.
         */ 
        function updatedCells (detail:CellUpdate) :void;
        
        /**
         * The client should synchronize its clock to the given instance of the server time.
         */ 
        function timeSync (serverTime:Number) :void;
        
        /**
         * The client should update the state of a single cell.
         */ 
        function updateCell (detail:CellState) :void;      
 	}
}