package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.Message;
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
        _gameId = _gameIdCounter++;
        _predatorIds = predatorIds;
        _preyId = preyId;
        _gameCompleteCallback = gameCompleteCallback;
        _roomCtrl = _gameCtrl.getRoom(roomId);
        _nameUtil = new NameUtil(_gameId);

        _state = STATE_WAITING_FOR_PLAYERS;
        _playersNeedingCheckin = predatorIds.slice();
        if (preyId >= 0) {
            _playersNeedingCheckin.push(preyId);
        }

        if (_roomCtrl == null) {
            log.warning("Failed to get RoomSubControl", "roomId", roomId);
            return;
        }

        _events.registerListener(_gameCtrl.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
    }

    override public function playerLeft (playerId :int) :void
    {
        if (playerId == _preyId) {
            _preyId = -1;
        } else {
            ArrayUtil.removeFirst(_predatorIds, playerId);
        }

        if (_state == STATE_WAITING_FOR_PLAYERS) {
            ArrayUtil.removeFirst(_playersNeedingCheckin, playerId);
            startGameIfReady();
        }
    }

    public function shutdown () :void
    {
        _timerMgr.shutdown();
        _events.freeAllHandlers();
    }

    override public function get gameId () :int
    {
        return _gameId;
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
        case ClientReadyMsg.NAME:
            if (_state != STATE_WAITING_FOR_PLAYERS) {
                logBadMessage(e, "game already started");

            } else {
                if (!ArrayUtil.removeFirst(_playersNeedingCheckin, e.senderId)) {
                    logBadMessage(e, "unrecognized player");
                }
                startGameIfReady();
            }
            break;

        // resend these messages to all the clients
        case CreateBonusMsg.NAME:
        case CurrentScoreMsg.NAME:
            if (this.isPlaying) {
                resendMessage(e);
            }
            break;

        default:
            logBadMessage(e, "unrecognized message type");
            break;
        }
    }

    protected function logBadMessage (e :MessageReceivedEvent, problemText :String = "") :void
    {
        log.warning(
            "Bad game message",
            "name", _nameUtil.decodeName(e.name),
            "sender", e.senderId,
            "problem", problemText);
    }

    protected function startGameIfReady () :void
    {
        if (_state != STATE_WAITING_FOR_PLAYERS) {
            return;
        }

        if (_playersNeedingCheckin.length == 0) {
            _state = STATE_PLAYING;
            sendMessage(StartGameMsg.create(_predatorIds, _preyId));
            _timerMgr.createTimer(Constants.GAME_TIME * 1000, 1, onGameOver).start();
        }
    }

    protected function onGameOver () :void
    {
        if (_state != STATE_GAME_OVER) {
            _state = STATE_GAME_OVER;
            // TODO: report scores back to the AVRG
        }
    }

    protected function sendMessage (msg :Message) :void
    {
        _roomCtrl.sendMessage(_nameUtil.encodeName(msg.name), _msgMgr.serializeMsg(msg));
    }

    protected function resendMessage (e :MessageReceivedEvent) :void
    {
        _roomCtrl.sendMessage(e.name, e.value);
    }

    protected function get isGameOver () :Boolean
    {
        return _state == STATE_GAME_OVER;
    }

    protected function get isPlaying () :Boolean
    {
        return _state == STATE_PLAYING;
    }

    protected var _gameId :int;
    protected var _state :int;
    protected var _predatorIds :Array;
    protected var _preyId :int;
    protected var _gameCompleteCallback :Function;
    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _roomCtrl :RoomSubControlServer;
    protected var _nameUtil :NameUtil;

    protected var _playersNeedingCheckin :Array;

    protected static var _gameIdCounter :int;
    protected static var _gameCtrl :AVRServerGameControl;
    protected static var _msgMgr :BasicMessageManager = new BasicMessageManager();

    protected static var log :Log = Log.getLog(Server);

    protected static const STATE_WAITING_FOR_PLAYERS :int = 0;
    protected static const STATE_PLAYING :int = 1;
    protected static const STATE_GAME_OVER :int = 2;
}

}
