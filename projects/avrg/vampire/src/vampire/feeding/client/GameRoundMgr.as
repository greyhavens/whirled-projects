package vampire.feeding.client {

import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.PropertyChangedEvent;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class GameRoundMgr
{
    public function GameRoundMgr ()
    {
        _events.registerListener(
            ClientCtx.props,
            PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function reportReadyForNextRound () :void
    {
        if (!ClientCtx.isConnected) {
            // in offline testing mode, just start the game immediately
            startRound();

        } else {
            if (!_ready) {
                log.info("Client ready for next round", "playerId", ClientCtx.localPlayerId);
                _ready = true;
                ClientCtx.msgMgr.sendMessage(ClientReadyMsg.create());
            }
        }
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == Props.STATE && e.newValue == Constants.STATE_PLAYING) {
            if (!_ready) {
                log.warning("Round started before we were ready!");
            } else {
                log.info("Starting the game!");
                startRound();
                _ready = false;
            }
        }
    }

    protected function startRound () :void
    {
        ClientCtx.mainLoop.unwindToMode(new GameMode());
    }

    protected var _ready :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var log :Log = Log.getLog(GameRoundMgr);
}

}
