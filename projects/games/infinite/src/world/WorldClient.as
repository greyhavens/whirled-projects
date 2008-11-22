package world
{
	import server.Messages.CellState;
	import server.Messages.CellUpdate;
	import server.Messages.EnterLevel;
	import server.Messages.InventoryUpdate;
	import server.Messages.LevelComplete;
	import server.Messages.LevelUpdate;
	import server.Messages.PathStart;
	
	public interface WorldClient extends Chronometer
	{
		/**
		 * A player entered a level.
		 */
        function enterLevel (detail:EnterLevel) :void;
        
        /**
         * The level is complete.
         */        
        function levelComplete (detail:LevelComplete) :void;
        
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
        
        /**
         * The client's player has received an item and this should be displayed in the inventory.
         */
        function receiveItem (detail:InventoryUpdate) :void;
        
        /**
         * The item at the given position in the inventory has been used and should be removed from play.
         */ 
        function itemUsed (position:int) :void;
                        
        /**
         * The requested path was not available.
         */ 
        function pathUnavailable () :void         
 	}
}