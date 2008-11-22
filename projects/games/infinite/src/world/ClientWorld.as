package world
{
	import arithmetic.BoardCoordinates;
	
	import flash.events.IEventDispatcher;
	
	import server.Messages.Neighborhood;
	
	/**
	 * This is the principal interface used to access the shared world.  In standalone, a local
	 * implementation will be provided, otherwise an implementation which communicated with the
	 * server via messages will be used.
	 */
	public interface ClientWorld extends IEventDispatcher
	{	
		/**
		 * Return a human readable string describing the type of this world.
		 */	
		function get worldType () :String
		
		/**
		 * A request from the specified client to enter the world.
		 */
		function enter (client:WorldClient) :void
		
		/**
		 * Return the id of this client.
		 */
		function get clientId () :int
		
		/**
		 * Return a string name for the given player id.
		 */
		function nameForPlayer (id:int) :String		
		
		/**
		 * Propose to the world that the player be moved to the coordinates supplied.
		 */
		function proposeMove (coords:BoardCoordinates) :void		
		
		/**
		 * Inform the world that the player has completed a move and is now at the location
		 * specified.
		 */
		function moveComplete (coords:BoardCoordinates) :void
		
		/**
		 * Request that a region of cells be updated soon.
		 */
		function requestCellUpdate (hood:Neighborhood) :void
		
		/**
		 * Request to use the item at the given inventory position.
		 */
		function useItem (position:int) :void
		
		/**
		 * Request to move to the next level.
		 */
		function nextLevel () :void
	}
}