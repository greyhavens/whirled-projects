package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.Dictionary;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class Server extends FeedingServer
{
    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        if (_inited) {
            throw new Error("init has already been called");
        }

        ServerCtx.init(gameCtrl);

        _inited = true;
    }

    public function Server (roomId :int,
                            predatorId :int,
                            preyId :int,
                            preyBlood :Number,
                            preyBloodType :int,
                            gameStartedCallback :Function,
                            roundCompleteCallback :Function,
                            gameCompleteCallback :Function,
                            playerLeftCallback :Function)
    {
        if (!_inited) {
            throw new Error("FeedingGameServer.init has not been called");
        }

        log.info(
            "New server starting",
            "roomId", roomId,
            "predatorId", predatorId,
            "preyId", preyId,
            "preyBlood", preyBlood);

        _ctx.server = this;
        _ctx.gameId = _gameIdCounter++;
        _ctx.playerIds = [];
        if (preyId != Constants.NULL_PLAYER) {
            _ctx.playerIds.push(preyId);
        }
        _ctx.playerIds.push(predatorId);
        _ctx.preyId = preyId;
        _ctx.preyIsAi = (_ctx.preyId == Constants.NULL_PLAYER);
        _ctx.preyBlood = preyBlood;
        _ctx.preyBloodType = preyBloodType;
        _ctx.gameStartedCallback = gameStartedCallback;
        _ctx.roundCompleteCallback = roundCompleteCallback;
        _ctx.gameCompleteCallback = gameCompleteCallback;
        _ctx.playerLeftCallback = playerLeftCallback;

        _ctx.roomCtrl = _ctx.gameCtrl.getRoom(roomId);
        _ctx.nameUtil = new NameUtil(_ctx.gameId);
        _ctx.props = new GamePropControl(_ctx.gameId, _ctx.roomCtrl.props);

        // Players are stored as a Dictionary property:
        // Dictionary<playerId:int, null>
        var playersDict :Dictionary = new Dictionary();
        for each (var predatorId :int in predatorIds) {
            playersDict[predatorId] = false;
        }
        if (preyId != Constants.NULL_PLAYER) {
            playersDict[preyId] = false;
        }
        _ctx.props.set(Props.PLAYERS, playersDict);
        _ctx.props.set(Props.LOBBY_LEADER, predatorId);
        _ctx.props.set(Props.PREY_ID, preyId);
        _ctx.props.set(Props.MODE, null);

        _events.registerListener(
            _ctx.gameCtrl.game,
            MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        setMode(Constants.MODE_LOBBY);
    }

    public function setMode (modeName :String) :void
    {
        if (_ctx.props.get(Props.MODE) == modeName) {
            log.warning("setMode failed; already in requested mode", "mode", modeName);
            return;
        }

        if (_serverMode != null) {
            _serverMode.shutdown();
            _serverMode = null;
        }

        var newMode :ServerMode;
        switch (modeName) {
        case Constants.MODE_LOBBY:
            newMode = new ServerLobbyMode(_ctx);
            break;

        case Constants.MODE_WAITING_FOR_CHECKIN:
            newMode = new ServerWaitForCheckinMode(_ctx);
            break;

        case Constants.MODE_PLAYING:
            if (!_gameStarted) {
                _gameStarted = true;
                _ctx.gameStartedCallback();
            }
            newMode = new ServerGameMode(_ctx);
            break;
        }

        if (newMode != null) {
            log.info("Setting new mode", "mode", modeName);
            _serverMode = newMode;
            _serverMode.run();
            _ctx.props.set(Props.MODE, modeName);

        } else {
            log.warning("unrecognized mode", "mode", modeName);
        }
    }

    public function bootPlayer (playerId :int) :void
    {
        _ctx.sendMessage(ClientBootedMsg.create(), playerId);
        playerLeft(playerId);
    }

    override public function addPredator (playerId :int) :Boolean
    {
        // we can only add players if the game hasn't started yet
        if (!this.hasStarted || ArrayUtil.contains(_ctx.playerIds, playerId)) {
            return false;
        }

        _ctx.playerIds.push(playerId);
        _ctx.props.setIn(Props.PLAYERS, playerId, false);

        return true;
    }

    override public function playerLeft (playerId :int) :void
    {
        if (playerId == _ctx.preyId) {
            _ctx.preyId = Constants.NULL_PLAYER;
        }

        var oldLobbyLeader :int = this.primaryPredatorId;
        ArrayUtil.removeFirst(_ctx.playerIds, playerId);
        var newLobbyLeader :int = this.primaryPredatorId;

        _ctx.props.setIn(Props.PLAYERS, playerId, null);
        if (oldLobbyLeader != newLobbyLeader) {
            _ctx.props.set(Props.LOBBY_LEADER, newLobbyLeader);
        }

        if (_ctx.playerIds.length == 0) {
            // If the last predator or prey just left the game, we're done and should shut down
            // prematurely
            shutdown();

        } else {
            if (!_noMoreFeeding && !_ctx.canContinueFeeding()) {
                // If the prey has left, or all the predators have left, no more feeding
                // can take place.
                _noMoreFeeding = true;
                _ctx.sendMessage(NoMoreFeedingMsg.create());
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

    override public function get preyId () :int
    {
        return _ctx.preyId;
    }

    override public function get predatorIds () :Array
    {
        var ids :Array = _ctx.playerIds.slice();
        ArrayUtil.removeFirst(ids, _ctx.preyId);
        return ids;
    }

    override public function get primaryPredatorId () :int
    {
        return _ctx.getPrimaryPredatorId();
    }

    override public function get hasStarted () :Boolean
    {
        return _gameStarted;
    }

    override public function get lastRoundScore () :int
    {
        return _ctx.lastRoundScore;
    }

    protected function shutdown () :void
    {
        if (_serverMode != null) {
            _serverMode.shutdown();
            _serverMode = null;
        }

        // Tell any remaining players that we're done
        _ctx.sendMessage(GameEndedMsg.create());

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

        var messageHandled :Boolean;

        if (msg is ClientQuitMsg) {
            playerLeft(e.senderId);
            messageHandled = true;

        } else if (msg is AwardTrophyMsg) {
             // we trust clients on all trophy award requests
            var senderCtrl :PlayerSubControlServer = _ctx.gameCtrl.getPlayer(e.senderId);
            if (senderCtrl == null) {
                logBadMessage(e, "Couldn't get PlayerSubControlServer for player");

            } else {
                var trophyMsg :AwardTrophyMsg = msg as AwardTrophyMsg;
                senderCtrl.awardTrophy(trophyMsg.trophyName);
            }
            messageHandled = true;

        } else if (_serverMode != null) {
            messageHandled = _serverMode.onMsgReceived(e.senderId, msg);
        }

        if (!messageHandled) {
            logBadMessage(e, "unrecognized message type");
        }
    }

    protected function logBadMessage (e :MessageReceivedEvent, reason :String, err :Error = null)
        :void
    {
        _ctx.logBadMessage(e.senderId, _ctx.nameUtil.decodeName(e.name), reason, err);
    }

    protected var _ctx :ServerCtx = new ServerCtx();
    protected var _serverMode :ServerMode;

    protected var _noMoreFeeding :Boolean;
    protected var _gameStarted :Boolean;

    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var _inited :Boolean;
    protected static var _gameIdCounter :int;

    protected static var log :Log = Log.getLog(Server);
}

}
