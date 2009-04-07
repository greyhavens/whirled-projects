package vampire.feeding.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.net.MessageReceivedEvent;

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
                            preyBloodType :int,
                            aiPreyName :String,
                            feedingHost :FeedingHost)
    {
        if (!_inited) {
            throw new Error("FeedingGameServer.init has not been called");
        }

        log.info(
            "New Blood Bloom server starting",
            "roomId", roomId,
            "predatorId", predatorId,
            "preyId", preyId,
            "aiPreyName", aiPreyName);

        _ctx.server = this;
        _ctx.gameId = _gameIdCounter++;
        _ctx.roomCtrl = _ctx.gameCtrl.getRoom(roomId);
        _ctx.nameUtil = new NameUtil(_ctx.gameId);
        _ctx.props = new GamePropControl(_ctx.gameId, _ctx.roomCtrl.props);

        _ctx.playerIds = [];
        if (preyId != Constants.NULL_PLAYER) {
            _ctx.playerIds.push(preyId);
        }
        if (predatorId != Constants.NULL_PLAYER) {
            _ctx.playerIds.push(predatorId);
        }
        _ctx.preyId = preyId;
        _ctx.preyIsAi = (_ctx.preyId == Constants.NULL_PLAYER);
        _ctx.preyBloodType = preyBloodType;
        _ctx.aiPreyName = aiPreyName;
        _ctx.feedingHost = feedingHost;

        _ctx.props.set(Props.ALL_PLAYERS, FeedingUtil.arrayToDict(_ctx.playerIds), true);
        _ctx.props.set(Props.LOBBY_LEADER, predatorId, true);
        _ctx.props.set(Props.MODE_NAME, null, true);

        _events.registerListener(
            _ctx.gameCtrl.game,
            MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);

        setMode(Constants.MODE_LOBBY);
    }

    override public function shutdown () :void
    {
        log.info("Shutting down Blood Bloom server");

        if (_serverMode != null) {
            _serverMode.shutdown();
            _serverMode = null;
        }

        // Tell any remaining players that we're done
        _ctx.sendMessage(GameEndedMsg.create());

        _events.freeAllHandlers();
        _events = null;

        _ctx = null;
    }

    public function setMode (modeName :String) :void
    {
        if (_ctx.modeName == modeName) {
            log.warning("setMode failed; already in requested mode", "modeName", modeName);
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

        case Constants.MODE_PLAYING:
            if (!_gameStarted) {
                _gameStarted = true;
                _ctx.feedingHost.onGameStarted();
            }
            newMode = new ServerGameMode(_ctx);
            break;
        }

        if (newMode != null) {
            log.info("Setting new mode", "modeName", modeName);
            _serverMode = newMode;
            _serverMode.run();

        } else {
            log.warning("unrecognized mode", "modeName", modeName);
        }
    }

    public function bootPlayer (playerId :int) :void
    {
        _ctx.sendMessage(ClientBootedMsg.create(), playerId);
        playerLeft(playerId);
    }

    override public function addPredator (playerId :int) :Boolean
    {
        if (_ctx.bloodBondProgress > 0) {
            _ctx.bloodBondProgress = 0;
        }

        _ctx.playerIds.push(playerId);
        _ctx.props.setIn(Props.ALL_PLAYERS, playerId, false, true);
        updateLobbyLeader();

        return true;
    }

    override public function playerLeft (playerId :int) :void
    {
        if (playerId == _ctx.preyId) {
            _ctx.preyId = Constants.NULL_PLAYER;
        }

        if (_ctx.bloodBondProgress > 0) {
            _ctx.bloodBondProgress = 0;
        }

        ArrayUtil.removeFirst(_ctx.playerIds, playerId);
        _ctx.props.setIn(Props.ALL_PLAYERS, playerId, null, true);
        updateLobbyLeader();

        _ctx.feedingHost.onPlayerLeft(playerId);

        if (_ctx.playerIds.length == 0) {
            // If the last predator or prey just left the game, the game is complete.
            _ctx.feedingHost.onGameComplete();

        } else if (_serverMode != null) {
            _serverMode.playerLeft(playerId);
        }
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
        return _ctx.lobbyLeader;
    }

    override public function get hasStarted () :Boolean
    {
        return _gameStarted;
    }

    override public function get lastRoundScore () :int
    {
        return _ctx.lastRoundScore;
    }

    protected function updateLobbyLeader () :void
    {
        if (!ArrayUtil.contains(_ctx.playerIds, _ctx.lobbyLeader)) {
            for each (var playerId :int in _ctx.playerIds) {
                if (playerId != _ctx.preyId) {
                    _ctx.lobbyLeader = playerId;
                    break;
                }
            }
        }
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
        _ctx.logBadMessage(log, e.senderId, _ctx.nameUtil.decodeName(e.name), reason, err);
    }

    protected var _ctx :ServerCtx = new ServerCtx();
    protected var _serverMode :ServerMode;
    protected var _gameStarted :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var _inited :Boolean;
    protected static var _gameIdCounter :int;

    protected static var log :Log = Log.getLog(Server);
}

}
