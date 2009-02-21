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
            startRound([ ClientCtx.localPlayerId ], Constants.NULL_PLAYER);

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
                var msg :StartRoundMsg = e.msg as StartRoundMsg;
                startRound(msg.playerIds, msg.preyId);
                _ready = false;
            }
        }
    }

    protected function startRound (playerIds :Array, preyId :int) :void
    {
        ClientCtx.mainLoop.unwindToMode(new GameMode(playerIds, preyId));
    }

    protected var _ready :Boolean;
    protected var _msgMgr :ClientMsgMgr;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var log :Log = Log.getLog(GameRoundMgr);
}

}
