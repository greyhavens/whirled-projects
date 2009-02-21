package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.contrib.simplegame.util.Rand;
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

    public function Server (roomId :int, predatorIds :Array, preyId :int, preyBlood :Number,
                            roundCompleteCallback :Function, gameCompleteCallback :Function)
    {
         if (!_inited) {
            throw new Error("FeedingGameServer.init has not been called");
        }

        _gameId = _gameIdCounter++;
        _playerIds = predatorIds.slice();
        if (preyId != Constants.NULL_PLAYER) {
            _playerIds.push(preyId);
        }
        _preyId = preyId;
        _preyBlood = preyBlood;
        _roundCompleteCallback = roundCompleteCallback;
        _gameCompleteCallback = gameCompleteCallback;
        _roomCtrl = _gameCtrl.getRoom(roomId);
        _nameUtil = new NameUtil(_gameId);

        waitForPlayers();

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
            _preyId = 0;
        }

        ArrayUtil.removeFirst(_playerIds, playerId);

        if (_playerIds.length == 0) {
            // If the last predator or prey just left the game, we're done and should shut down
            // prematurely
            shutdown();

        } else {
            if ((_preyId == 0 || _playerIds.length <= 1) && !_noMoreFeeding) {
                // If the prey has left, or all the predators have left, no more feeding
                // can take place.
                _noMoreFeeding = true;
                sendMessage(NoMoreFeedingMsg.create());
            }

            if (_state == STATE_WAITING_FOR_PLAYERS) {
                ArrayUtil.removeFirst(_playersNeedingCheckin, playerId);
                startGameIfReady();

            } else if (_state == STATE_WAITING_FOR_SCORES) {
                ArrayUtil.removeFirst(_playersNeedingScoreUpdate, playerId);
                endRoundIfReady();
            }
        }
    }

    override public function get gameId () :int
    {
        return _gameId;
    }

    override public function get playerIds () :Array
    {
        return _playerIds.slice();
    }

    override public function get lastRoundScore () :int
    {
        if (_noMoreFeeding || _finalScores == null) {
            return 0;

        } else {
            var totalScore :int;
            _finalScores.forEach(
                function (playerId :int, score :int) :void {
                    totalScore += score;
                });
            return totalScore;
        }
    }

    protected function waitForPlayers () :void
    {
        _state = STATE_WAITING_FOR_PLAYERS;
        _playersNeedingCheckin = _playerIds.slice();
    }

    protected function shutdown () :void
    {
        // Tell any remaining players that we're done
        sendMessage(GameEndedMsg.create());

        _timerMgr.shutdown();
        _events.freeAllHandlers();
        _gameCompleteCallback();

        log.info("Shutting down Blood Bloom server");
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.isFromServer() || !_nameUtil.isForGame(e.name)) {
            // don't listen to messages that we've sent, or that aren't for this
            // particular game
            return;
        }

        var name :String = _nameUtil.decodeName(e.name);
        var msg :Message = _msgMgr.deserializeMessage(name, e.value);
        if (msg == null) {
            return;
        }

        if (!ArrayUtil.contains(_playerIds, e.senderId)) {
            logBadMessage(e, "unrecognized player (maybe they were just booted?)");
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

                    // When at least one player has checked in, start a timer that will force
                    // the game to start after a maximum amount of time has elapsed, even if
                    // the rest of the players haven't joined yet.
                    if (_state != STATE_PLAYING && _waitForPlayersTimer == null) {
                        _waitForPlayersTimer = _timerMgr.createTimer(
                            Constants.WAIT_FOR_PLAYERS_TIMEOUT * 1000, 1, startGameNow);
                        _waitForPlayersTimer.start();
                        sendMessage(RoundStartingSoonMsg.create());
                    }
                }
            }
            break;

        case RoundScoreMsg.NAME:
            if (_state != STATE_WAITING_FOR_SCORES) {
                logBadMessage(e, "not waiting for scores");

            } else {
                if (!ArrayUtil.removeFirst(_playersNeedingScoreUpdate, e.senderId)) {
                    logBadMessage(e, "unrecognized player, or player already reported score");
                } else {
                    _finalScores.put(e.senderId, (msg as RoundScoreMsg).score);
                    endRoundIfReady();
                }
            }
            break;

        case CreateBonusMsg.NAME:
            // bonuses are delivered to another randomly-picked player
            var targetPlayerId :int = getAnotherPlayer(e.senderId);
            if (targetPlayerId != Constants.NULL_PLAYER) {
                sendMessage(msg, targetPlayerId);
            }
            break;

        case CurrentScoreMsg.NAME:
            if (_state == STATE_PLAYING) {
                resendMessage(e);
            }
            break;

        case ClientQuitMsg.NAME:
            playerLeft(e.senderId);
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
            startGameNow();
        }
    }

    protected function startGameNow (...ignored) :void
    {
        if (_state != STATE_WAITING_FOR_PLAYERS) {
            return;
        }

        _state = STATE_PLAYING;

        if (_waitForPlayersTimer != null) {
            _waitForPlayersTimer.cancel();
            _waitForPlayersTimer = null;
        }

        // any players who haven't checked in when the game starts are booted from the game
        for each (var playerId :int in _playersNeedingCheckin) {
            log.info("Booting unresponsive player", "playerId", playerId);
            sendMessage(ClientBootedMsg.create(), playerId);
            playerLeft(playerId);
        }

        _playersNeedingCheckin = [];

        sendMessage(StartRoundMsg.create(_playerIds.slice(), _preyId));
        _timerMgr.createTimer(Constants.GAME_TIME * 1000, 1, onTimeOver).start();
    }

    protected function onTimeOver (...ignored) :void
    {
        if (_state == STATE_PLAYING) {
            _state = STATE_WAITING_FOR_SCORES;
            _playersNeedingScoreUpdate = _playerIds.slice();
            _finalScores = new HashMap();
            sendMessage(RoundOverMsg.create());
        }
    }

    protected function endRoundIfReady () :void
    {
        if (_state != STATE_WAITING_FOR_SCORES) {
            return;
        }

        if (_playersNeedingScoreUpdate.length == 0) {
            _state = STATE_ROUND_OVER;
            // Send the final scores to the clients.
            var preyBloodStart :Number = _preyBlood;
            _preyBlood = _roundCompleteCallback();
            sendMessage(RoundResultsMsg.create(_finalScores, preyBloodStart, _preyBlood));
            // move to the waiting_for_players state
            waitForPlayers();
        }
    }

    protected function getAnotherPlayer (playerId :int) :int
    {
        // returns a random player id

        var players :Array = this.playerIds.slice();
        if (players.length <= 1) {
            return Constants.NULL_PLAYER;
        }

        ArrayUtil.removeFirst(players, playerId);
        return Rand.nextElement(players, Rand.STREAM_GAME);
    }

    protected function sendMessage (msg :Message, toPlayer :int = 0) :void
    {
        var name :String = _nameUtil.encodeName(msg.name);
        var val :Object = _msgMgr.serializeMsg(msg);
        if (toPlayer == 0) {
            _roomCtrl.sendMessage(name, val);
        } else {
            _gameCtrl.getPlayer(toPlayer).sendMessage(name, val);
        }

        log.info("Sending msg '" + msg.name + "' to " + (toPlayer != 0 ? toPlayer : "ALL"));
    }

    protected function resendMessage (e :MessageReceivedEvent) :void
    {
        _roomCtrl.sendMessage(e.name, e.value);
    }

    protected var _gameId :int;
    protected var _state :int;
    protected var _playerIds :Array;
    protected var _preyId :int;
    protected var _preyBlood :Number;
    protected var _roundCompleteCallback :Function;
    protected var _gameCompleteCallback :Function;
    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _waitForPlayersTimer :ManagedTimer;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _roomCtrl :RoomSubControlServer;
    protected var _nameUtil :NameUtil;
    protected var _finalScores :HashMap; // Map<playerId, score>
    protected var _noMoreFeeding :Boolean;

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
    protected static const STATE_ROUND_OVER :int = 3;
}

}
