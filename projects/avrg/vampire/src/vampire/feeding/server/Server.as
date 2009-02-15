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
        if (_inited) {
            throw new Error("init has already been called");
        }

        _gameCtrl = gameCtrl;
        _msgMgr = new BasicMessageManager();
        Util.initMessageManager(_msgMgr);

        _inited = true;
    }

    public function Server (roomId :int, predatorIds :Array, preyId :int,
                            gameCompleteCallback :Function)
    {
         if (!_inited) {
            throw new Error("FeedingGameServer.init has not been called");
        }

        _gameId = _gameIdCounter++;
        _predatorIds = predatorIds;
        _preyId = preyId;
        _gameCompleteCallback = gameCompleteCallback;
        _roomCtrl = _gameCtrl.getRoom(roomId);
        _nameUtil = new NameUtil(_gameId);

        _state = STATE_WAITING_FOR_PLAYERS;
        _playersNeedingCheckin = this.playerIds;

        if (_roomCtrl == null) {
            log.warning("Failed to get RoomSubControl", "roomId", roomId);
            return;
        }

        _events.registerListener(_gameCtrl.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
    }

    override public function playerLeft (playerId :int) :Boolean
    {
        if (playerId == _preyId) {
            _preyId = -1;
        } else {
            ArrayUtil.removeFirst(_predatorIds, playerId);
        }

        if (_state == STATE_WAITING_FOR_PLAYERS) {
            ArrayUtil.removeFirst(_playersNeedingCheckin, playerId);
            startGameIfReady();

        } else if (_state == STATE_WAITING_FOR_SCORES) {
            ArrayUtil.removeFirst(_playersNeedingScoreUpdate, playerId);
            endGameIfReady();
        }

        // If the last predator or prey just left the game, we're done and should shut down
        // prematurely
        if (_predatorIds.length == 0 || _preyId == -1) {
            shutdown();
            return true;

        } else {
            return false;
        }
    }

    override public function get gameId () :int
    {
        return _gameId;
    }

    override public function get playerIds () :Array
    {
        var playerIds :Array = _predatorIds.slice();
        if (_preyId >= 0) {
            playerIds.push(_preyId);
        }

        return playerIds;
    }

    override public function get finalScore () :int
    {
        return _finalScore;
    }

    protected function shutdown () :void
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
        var msg :Message = _msgMgr.deserializeMessage(name, e.value);
        if (msg == null) {
            return;
        }

        log.info("Received message", "name", msg.name, "sender", e.senderId);

        switch (name) {
        case ClientReadyMsg.NAME:
            if (_state != STATE_WAITING_FOR_PLAYERS) {
                logBadMessage(e, "game already started");

            } else {
                if (!ArrayUtil.removeFirst(_playersNeedingCheckin, e.senderId)) {
                    logBadMessage(e, "unrecognized player, or player already checked in");
                } else {
                    startGameIfReady();
                }
            }
            break;

        case FinalScoreMsg.NAME:
            if (_state != STATE_WAITING_FOR_SCORES) {
                logBadMessage(e, "not waiting for scores");

            } else {
                if (!ArrayUtil.removeFirst(_playersNeedingScoreUpdate, e.senderId)) {
                    logBadMessage(e, "unrecognized player, or player already reported score");
                } else {
                    _finalScore += (msg as FinalScoreMsg).score;
                    endGameIfReady();
                }
            }
            break;

        // resend these messages to all the clients
        case CreateBonusMsg.NAME:
        case CurrentScoreMsg.NAME:
            if (_state == STATE_PLAYING) {
                resendMessage(e);
            }
            break;

        default:
            logBadMessage(e, "unrecognized message type");
            break;
        }
    }

    protected function logBadMessage (e :MessageReceivedEvent,
                                      problemText :String = null,
                                      err :Error = null) :void
    {
        var args :Array = [
            "Bad game message",
            "name", _nameUtil.decodeName(e.name),
            "sender", e.senderId
        ];

        if (problemText != null) {
            args.push("problem", problemText);
        }

        if (err != null) {
            args.push(err);
        }

        log.warning.apply(null, args);
    }

    protected function startGameIfReady () :void
    {
        if (_state != STATE_WAITING_FOR_PLAYERS) {
            return;
        }

        if (_playersNeedingCheckin.length == 0) {
            _state = STATE_PLAYING;
            sendMessage(StartGameMsg.create(_predatorIds, _preyId));
            _timerMgr.createTimer(Constants.GAME_TIME * 1000, 1, onTimeOver).start();
        }
    }

    protected function onTimeOver () :void
    {
        if (_state == STATE_PLAYING) {
            _state = STATE_WAITING_FOR_SCORES;
            _playersNeedingScoreUpdate = this.playerIds;
            sendMessage(GameOverMsg.create());
        }
    }

    protected function endGameIfReady () :void
    {
        if (_state != STATE_WAITING_FOR_SCORES) {
            return;
        }

        if (_playersNeedingScoreUpdate.length == 0) {
            _state = STATE_GAME_OVER;
            _gameCompleteCallback();
            shutdown();
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

    protected var _gameId :int;
    protected var _state :int;
    protected var _predatorIds :Array;
    protected var _preyId :int;
    protected var _gameCompleteCallback :Function;
    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _roomCtrl :RoomSubControlServer;
    protected var _nameUtil :NameUtil;
    protected var _finalScore :int;

    protected var _playersNeedingCheckin :Array;
    protected var _playersNeedingScoreUpdate :Array;

    protected static var _inited :Boolean;
    protected static var _gameIdCounter :int;
    protected static var _gameCtrl :AVRServerGameControl;
    protected static var _msgMgr :BasicMessageManager = new BasicMessageManager();

    protected static var log :Log = Log.getLog(Server);

    protected static const STATE_WAITING_FOR_PLAYERS :int = 0;
    protected static const STATE_PLAYING :int = 1;
    protected static const STATE_WAITING_FOR_SCORES :int = 2;
    protected static const STATE_GAME_OVER :int = 3;
}

}
