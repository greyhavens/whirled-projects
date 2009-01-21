package popcraft.server {

import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerContext.gameCtrl = new GameControl(this);
        ServerContext.seatingMgr.init(ServerContext.gameCtrl);
        ServerContext.lobbyConfig.init(ServerContext.gameCtrl, ServerContext.seatingMgr);

        // We don't have anything to do in single-player games
        if (ServerContext.seatingMgr.numExpectedPlayers < 2) {
            log.info("Singleplayer game. Not starting server.");
            return;
        }

        log.info("Starting server");

        // We want to shutdown the lobby when the game starts, and start it up
        // when the game ends.
        ServerContext.gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED,
            function (...ignored) :void {
                stopLobby();
            });

        ServerContext.gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED,
            function (...ignored) :void {
                startLobby();
            });

        startLobby();
    }

    protected function startLobby () :void
    {
        _curLobby = new ServerLobby();
    }

    protected function stopLobby () :void
    {
        if (_curLobby != null) {
            _curLobby.shutdown();
            _curLobby = null;
        }
    }

    protected var _gameStarted :Boolean;
    protected var _curLobby :ServerLobby;

    protected var log :Log = Log.getLog(Server);
}

}
