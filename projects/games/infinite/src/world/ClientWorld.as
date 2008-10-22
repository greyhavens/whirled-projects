package world
{
	import flash.events.IEventDispatcher;
	
	/**
	 * This is the principal interface used to access the shared world.  In standalone, a local
	 * implementation will be provided, otherwise an implementation which communicated with the
	 * server via messages will be used.
	 */
	public interface ClientWorld extends IEventDispatcher
	{
		
	}
}