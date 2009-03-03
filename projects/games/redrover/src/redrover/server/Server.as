package redrover.server {

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
                startGame();
            });

        ServerCtx.gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED,
            function (...ignored) :void {
                stopGame();
            });
    }

    protected function startGame () :void
    {
        log.info("Game started");
    }

    protected function stopGame () :void
    {
        log.info("Game ended");
    }

    protected var log :Log = Log.getLog(Server);
}

}
