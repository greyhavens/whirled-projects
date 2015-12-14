package
{
    import client.FrameEvent;
    
	public interface PlayerAction
	{
		/**
		 * Player actions receive an event on each frame
		 */
		function handleFrameEvent (event:FrameEvent) :void
	}
}