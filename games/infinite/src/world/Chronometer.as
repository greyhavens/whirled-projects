package world
{
	/**
	 * An interface for objects that are synchronized with the server.
	 */
	public interface Chronometer
	{
		/**
		 * Return the working estimate for the current time on the server.
		 */
        function get serverTime () :Number;		
	}
}