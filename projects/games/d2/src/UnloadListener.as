package {

import flash.events.Event;

/**
 * All implementors of this interface will be notified about game shutdown.
 */
public interface UnloadListener
{
    function handleUnload (event :Event) :void;
}
}
