package vampire.combat.server
{
import aduros.net.REMOTE;
import aduros.net.RemoteProxy;

import com.threerings.util.Log;

public class CombatServer
{
    public function CombatServer(gameServiceServer :RemoteProxy)
    {
        _gameServiceServer = gameServiceServer;
    }

    REMOTE function doThing (playerId :int, arg :int) :void
    {
        log.debug("doThing", "playerId", playerId, "arg", arg);
        _gameServiceServer.doThingClient(arg);
    }


    protected var _gameServiceServer :RemoteProxy;
    protected static var log :Log = Log.getLog(CombatServer);

}
}
