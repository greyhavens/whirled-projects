package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;
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

        ServerCtx.init(gameCtrl);

        _inited = true;
    }

    public function Server (roomId :int, predatorIds :Array, preyId :int, preyBlood :Number,
                            preyBloodType :int, roundCompleteCallback :Function,
                            gameCompleteCallback :Function, playerLeftCallback :Function)
    {
        if (!_inited) {
            throw new Error("FeedingGameServer.init has not been called");
        }

        log.info(
            "New server starting",
            "roomId", roomId,
            "predatorIds", predatorIds,
            "preyId", preyId,
            "preyBlood", preyBlood);

        _ctx.server = this;
        _ctx.gameId = _gameIdCounter++;
        _ctx.playerIds = predatorIds.slice();
        if (preyId != Constants.NULL_PLAYER) {
            _ctx.playerIds.push(preyId);
        }
        _ctx.preyId = preyId;
        _ctx.preyIsAi = (_ctx.preyId == Constants.NULL_PLAYER);
        _ctx.preyBlood = preyBlood;
        _ctx.preyBloodType = preyBloodType;
        _ctx.roundCompleteCallback = roundCompleteCallback;
        _ctx.gameCompleteCallback = gameCompleteCallback;
        _ctx.playerLeftCallback = playerLeftCallback;

        _ctx.roomCtrl = _ctx.gameCtrl.getRoom(roomId);
        _ctx.nameUtil = new NameUtil(_ctx.gameId);
        _ctx.props = new GamePropControl(_ctx.gameId, _ctx.roomCtrl.props);

        _events.registerListener(
            _ctx.gameCtrl.game,
            MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        waitForPlayers();
    }

    public function roundComplete (roundScore :int) :void
    {
        _lastRoundScore = roundScore;
        waitForPlayers();
    }

    override public function playerLeft (playerId :int) :void
    {
        if (playerId == _ctx.preyId) {
            _ctx.preyId = Constants.NULL_PLAYER;
        }

        ArrayUtil.removeFirst(_ctx.playerIds, playerId);

        if (_ctx.playerIds.length == 0) {
            // If the last predator or prey just left the game, we're done and should shut down
            // prematurely
            shutdown();

        } else {
            if (_gameStarted) {
                // Let all the clients know that somebody has left
                // (If the game hasn't yet started, the StartGameMsg hasn't been delivered,
                // and the clients don't know who is in the game yet.)
                _ctx.sendMessage(PlayerLeftMsg.create(playerId));
            }

            if (!_noMoreFeeding && !_ctx.canContinueFeeding()) {
                // If the prey has left, or all the predators have left, no more feeding
                // can take place.
                _noMoreFeeding = true;
                _ctx.sendMessage(NoMoreFeedingMsg.create());
            }

            if (_state == STATE_WAITING_FOR_PLAYERS) {
                ArrayUtil.removeFirst(_playersNeedingCheckin, playerId);
                startRoundIfReady();

            }

            if (_serverMode != null) {
                _serverMode.playerLeft(playerId);
            }
        }

        _ctx.playerLeftCallback(playerId);
    }

    override public function get gameId () :int
    {
        return _ctx.gameId;
    }

    override public function get playerIds () :Array
    {
        return _ctx.playerIds.slice();
    }

    override public function get lastRoundScore () :int
    {
        return _lastRoundScore;
    }

    protected function waitForPlayers () :void
    {
        setMode(null);
        _state = STATE_WAITING_FOR_PLAYERS;
        _playersNeedingCheckin = _ctx.playerIds.slice();
    }

    protected function shutdown () :void
    {
        setMode(null);

        // Tell any remaining players that we're done
        _ctx.sendMessage(GameEndedMsg.create());

        _timerMgr.shutdown();
        _events.freeAllHandlers();
        _ctx.gameCompleteCallback();

        log.info("Shutting down Blood Bloom server");
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.isFromServer() || !_ctx.nameUtil.isForGame(e.name)) {
            // don't listen to messages that we've sent, or that aren't for this
            // particular game
            return;
        }

        var name :String = _ctx.nameUtil.decodeName(e.name);
        var msg :Message = _ctx.msgMgr.deserializeMessage(name, e.value);
        if (msg == null) {
            return;
        }

        if (!ArrayUtil.contains(_ctx.playerIds, e.senderId)) {
            logBadMessage(e, "unrecognized player (maybe they were just booted?)");
            return;
        }

        log.info("Received message", "name", msg.name, "sender", e.senderId);

        if (_serverMode != null) {
            _serverMode.onMsgReceived(e.senderId, msg);
        }

        switch (name) {
        case ClientReadyMsg.NAME:
            if (_state != STATE_WAITING_FOR_PLAYERS) {
                logBadMessage(e, "game already started");

            } else {
                if (!ArrayUtil.removeFirst(_playersNeedingCheckin, e.senderId)) {
                    logBadMessage(e, "unrecognized player, or player already checked in");
                } else {
                    startRoundIfReady();

                    // When at least one player has checked in, start a timer that will force
                    // the game to start after a maximum amount of time has elapsed, even if
                    // the rest of the players haven't joined yet.
                    if (_state != STATE_IN_ROUND && _waitForPlayersTimer == null) {
                        _waitForPlayersTimer = _timerMgr.createTimer(
                            Constants.WAIT_FOR_PLAYERS_TIMEOUT * 1000, 1, startGameNow);
                        _waitForPlayersTimer.start();
                        _ctx.sendMessage(RoundStartingSoonMsg.create());
                    }
                }
            }
            break;

        case ClientQuitMsg.NAME:
            playerLeft(e.senderId);
            break;

        case AwardTrophyMsg.NAME:
            // we trust clients on all trophy award requests
            var senderCtrl :PlayerSubControlServer = _ctx.gameCtrl.getPlayer(e.senderId);
            if (senderCtrl == null) {
                logBadMessage(e, "Couldn't get PlayerSubControlServer for player");
            } else {
                var trophyMsg :AwardTrophyMsg = msg as AwardTrophyMsg;
                senderCtrl.awardTrophy(trophyMsg.trophyName);
            }
            break;

        default:
            logBadMessage(e, "unrecognized message type");
            break;
        }
    }

    protected function logBadMessage (e :MessageReceivedEvent, reason :String, err :Error = null)
        :void
    {
        _ctx.logBadMessage(e.senderId, _ctx.nameUtil.decodeName(e.name), reason, err);
    }

    protected function startRoundIfReady () :void
    {
        if (_state != STATE_WAITING_FOR_PLAYERS) {
            return;
        }

        if (_playersNeedingCheckin.length == 0) {
            startGameNow();
        } else {
            log.info("Waiting for " + _playersNeedingCheckin.length + " more players to start.");
        }
    }

    protected function startGameNow (...ignored) :void
    {
        if (_state != STATE_WAITING_FOR_PLAYERS || _noMoreFeeding) {
            return;
        }

        if (_waitForPlayersTimer != null) {
            _waitForPlayersTimer.cancel();
            _waitForPlayersTimer = null;
        }

        // any players who haven't checked in when the game starts are booted from the game
        for each (var playerId :int in _playersNeedingCheckin) {
            log.info("Booting unresponsive player", "playerId", playerId);
            _ctx.sendMessage(ClientBootedMsg.create(), playerId);
            playerLeft(playerId);
        }

        _playersNeedingCheckin = [];

        // If the game hasn't been started yet, let all the players know what the initial
        // setup of players is
        if (!_gameStarted) {
            _ctx.sendMessage(StartGameMsg.create(
                _ctx.playerIds.slice(),
                _ctx.preyId,
                _ctx.preyBloodType));

            _gameStarted = true;
        }

        _ctx.sendMessage(StartRoundMsg.create());
        _state = STATE_IN_ROUND;
        setMode(new ServerGame(_ctx));
    }

    protected function setMode (newMode :ServerMode) :void
    {
        if (_serverMode != null) {
            _serverMode.shutdown();
            _serverMode = null;
        }

        if (newMode != null) {
            _serverMode = newMode;
            _serverMode.run();
        }
    }

    protected var _ctx :ServerCtx = new ServerCtx();
    protected var _serverMode :ServerMode;

    protected var _state :int;
    protected var _waitForPlayersTimer :ManagedTimer;
    protected var _noMoreFeeding :Boolean;
    protected var _gameStarted :Boolean;
    protected var _lastRoundScore :int;

    protected var _timerMgr :TimerManager = new TimerManager();
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected var _playersNeedingCheckin :Array;

    protected static var _inited :Boolean;
    protected static var _gameIdCounter :int;

    protected static var log :Log = Log.getLog(Server);

    protected static const STATE_LOBBY :int = 0;
    protected static const STATE_WAITING_FOR_PLAYERS :int = 1;
    protected static const STATE_IN_ROUND :int = 2;
}

}
