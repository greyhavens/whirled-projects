package bloodbloom.server {

import bloodbloom.*;
import bloodbloom.net.*;

import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.game.GameControl;
import com.whirled.game.StateChangedEvent;

public class Server extends ServerObject
{
    public function Server ()
    {
        ServerCtx.gameCtrl = new GameControl(this, false);
        ServerCtx.msgMgr = new BasicMessageManager();
        ServerCtx.msgMgr.addMessageType(CreateBonusMsg);

        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_STARTED,
            onGameStarted);
        _events.registerListener(ServerCtx.gameCtrl.game, StateChangedEvent.GAME_ENDED,
            onGameEnded);
    }

    protected function onGameStarted (...ignored) :void
    {
        _game = new ServerGame();
    }

    protected function onGameEnded (...ignored) :void
    {
        if (_game != null) {
            _game.shutdown();
        }
    }

    protected var _game :ServerGame;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var log :Log = Log.getLog(Server);
}

}
