package bloodbloom.server {

import bloodbloom.*;
import bloodbloom.net.*;

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.TimerManager;
import com.whirled.net.MessageReceivedEvent;

public class ServerGame
{
    public function ServerGame ()
    {
        _timerMgr.createTimer(Constants.GAME_TIME * 1000, 1, onGameOver).start();
        _events.registerListener(ServerCtx.gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
    }

    public function shutdown () :void
    {
        _timerMgr.shutdown();
        _events.freeAllHandlers();
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.isFromServer()) {
            // don't listen to messages that we've sent
            return;
        }

        switch (e.name) {
        // resend these messages to all the clients
        case CreateBonusMsg.NAME:
        case CurrentScoreMsg.NAME:
            if (!_gameOver) {
                sendMessage(e.name, e.value);
            }
            break;
        }

    }

    protected function onGameOver (...ignored) :void
    {
        _gameOver = true;
    }

    protected function sendMessage (name :String, val :Object = null) :void
    {
        ServerCtx.gameCtrl.net.sendMessage(name, val);
    }

    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _gameOver :Boolean;
}

}
