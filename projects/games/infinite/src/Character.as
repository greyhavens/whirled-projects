package
{
	import flash.events.IEventDispatcher;
	
	import paths.Path;
	import paths.PathFollower;
	
	/**
	 * Represents an active agent within the game.
	 */
	public interface Character extends Viewable, Owner, PathFollower, IEventDispatcher
	{		
		/**
		 * Return the cell that the player currently occupies if the player is currently in a 
		 * cell, otherwise null.
		 */
		function get cell () :Cell;
		
		/**
		 * Set the objective in which this player will reside.
		 */
		function set objective (objective:Objective) :void;
		
		/**
		 * Follow the supplied path.
		 */
		function follow (path:Path) :void;		
	}
}