package popcraft.server {

import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this);
        ServerCtx.seatingMgr.init(ServerCtx.gameCtrl);
        ServerCtx.lobbyConfig.init(ServerCtx.gameCtrl, ServerCtx.seatingMgr);

        // We don't have anything to do in single-player games
        if (ServerCtx.seatingMgr.numExpectedPlayers < 2) {
            log.info("Singleplayer game. Not starting server.");
            return;
        }

        log.info("Starting server");

        // We want to shutdown the lobby when the game starts, and start it up
        // when the game ends.
        ServerCtx.gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED,
            function (...ignored) :void {
                stopLobby();
            });

        ServerCtx.gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED,
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
