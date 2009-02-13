package vampire.feeding.server {

import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.net.MessageReceivedEvent;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class Server extends FeedingGameServer
{
    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        _gameCtrl = gameCtrl;
        _msgMgr = new BasicMessageManager();
        Util.initMessageManager(_msgMgr);
    }

    public function Server (roomId :int, predatorIds :Array, preyId :int,
                            gameCompleteCallback :Function)
    {
        //ServerCtx.gameCtrl = new GameControl(this, false);
        _gameId = _gameIdCounter++;
        _predatorIds = predatorIds;
        _preyId = preyId;
        _gameCompleteCallback = gameCompleteCallback;
        _roomCtrl = _gameCtrl.getRoom(roomId);
        _nameUtil = new NameUtil(_gameId);

        if (_roomCtrl == null) {
            log.warning("Failed to get RoomSubControl", "roomId", roomId);
            return;
        }

        _timerMgr.createTimer(Constants.GAME_TIME * 1000, 1, onGameOver).start();
        /*_events.registerListener(ServerCtx.gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);*/
    }

    public function shutdown () :void
    {
        _timerMgr.shutdown();
        _events.freeAllHandlers();
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.isFromServer() || !_nameUtil.isForGame(e.name)) {
            // don't listen to messages that we've sent, or that aren't for this
            // paricular game
            return;
        }

        var name :String = _nameUtil.decodeName(e.name);
        switch (name) {
        // resend these messages to all the clients
        case CreateBonusMsg.NAME:
        case CurrentScoreMsg.NAME:
            if (!_gameOver) {
                sendMessage(name, e.value);
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
        _roomCtrl.sendMessage(_nameUtil.encodeName(name), val);
    }

    override public function get gameId () :int
    {
        return _gameId;
    }

    protected var _gameId :int;
    protected var _gameOver :Boolean;
    protected var _predatorIds :Array;
    protected var _preyId :int;
    protected var _gameCompleteCallback :Function;
    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _roomCtrl :RoomSubControlServer;
    protected var _nameUtil :NameUtil;

    protected static var _gameIdCounter :int;
    protected static var _gameCtrl :AVRServerGameControl;
    protected static var _msgMgr :BasicMessageManager = new BasicMessageManager();

    protected static var log :Log = Log.getLog(Server);
}

}
