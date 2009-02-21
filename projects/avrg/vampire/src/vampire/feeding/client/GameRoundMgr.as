package vampire.feeding.client {

import com.threerings.util.Log;
import com.whirled.contrib.EventHandlerManager;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class GameRoundMgr
{
    public function GameRoundMgr (msgMgr :ClientMsgMgr)
    {
        _msgMgr = msgMgr;
        _events.registerListener(msgMgr, ClientMsgEvent.MSG_RECEIVED, onMsgReceived);
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
                _msgMgr.sendMessage(ClientReadyMsg.create());
            }
        }
    }

    protected function onMsgReceived (e :ClientMsgEvent) :void
    {
        if (e.msg is StartRoundMsg) {
            if (!_ready) {
                log.warning("Received StartRoundMsg before we were ready!");
            } else {
                log.info("Received StartRoundMsg. Starting!");
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
    protected var _msgMgr :ClientMsgMgr;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var log :Log = Log.getLog(GameRoundMgr);
}

}
