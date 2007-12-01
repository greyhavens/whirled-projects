package {

/**
 * All implementors of this interface will be notified about game shutdown.
 */
public interface UnloadListener
{
    function handleUnload () :void;
}
}
