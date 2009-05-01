package vampire.server.feeding
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.EventCollecter;
import com.whirled.contrib.simplegame.ObjectMessage;

import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.Constants;
import vampire.feeding.FeedingHost;
import vampire.feeding.FeedingRoundResults;
import vampire.feeding.FeedingServer;
import vampire.feeding.variant.Variant;
import vampire.net.messages.MovePredAfterFeedingMsg;
import vampire.net.messages.StartFeedingClientMsg;
import vampire.server.AnalyserServer;
import vampire.server.PlayerData;
import vampire.server.Room;
import vampire.server.ServerContext;

public class FeedingRecord extends EventCollecter
    implements FeedingHost
{
    public function FeedingRecord(room :Room,
                                   gameId :int,
                                   predatorId :int,
                                   preyId :int,
                                   preyName :String,
                                   preyLocation :Array,
                                   gameFinishedCallback :Function)
    {
        _room = room;
        _gameId = gameId;
        _preyId = preyId;
        _preyInitialLocation = preyLocation;
        _gameFinishedCallback = gameFinishedCallback;
        startLobby(preyId, preyName, predatorId);
    }

    public function formBloodBond (playerId1 :int, playerId2 :int) :void
    {
        log.debug("formBloodBond", "playerId1", playerId1, "playerId2", playerId2);
        ServerContext.server.getPlayer(playerId1).bloodBond = playerId2;
        ServerContext.server.getPlayer(playerId2).bloodBond = playerId1;
    }

    public function getBloodBondPartner (playerId :int) :int
    {
        return ServerContext.server.getPlayer(playerId).bloodbond;
    }

    public function playerLeavesGame (playerId :int, moved :Boolean = false) :void
    {
        log.debug("playerLeavesGame", playerId, "playerId", "preyId", preyId);
//        if (moved && _gameServer.primaryPredatorId == playerId || preyId == playerId) {
//            _primaryPredMoved = true;
//        }

        if (!ArrayUtil.contains(_gameServer.playerIds, playerId)) {
            return;
        }

        if (_gameServer != null) {// && ArrayUtil.contains(_gameServer.playerIds, playerId)) {
            log.debug("playerLeavesGame", "playerId", playerId);

            //If we rely on checking the room for the presence of a player, we could
            //encounter a race condition, since this function could be called from a
            //player quitting the game.  The room would then remove the player,
            //and if we checked the room, the player would not be there, leading us
            //to believe that it's an AI player.
            if (ArrayUtil.contains(_gameServer.playerIds, playerId)) {
                _gameServer.playerLeft(playerId);

            }
        }
    }

    public function startLobby(preyId :int, preyName :String, predId :int) :void
    {
        log.debug("startGame()");

        var gamePreyId :int = _room.isPlayer(preyId) ? preyId : Constants.NULL_PLAYER;
        var preyBloodType :int = Logic.getPlayerBloodStrain(preyId);

        _gameServer = FeedingServer.create(_room.roomId,
                                                predId,
                                                gamePreyId,
                                                preyBloodType,
                                                preyName,
                                                Variant.NORMAL,
                                                this);

        log.debug("starting gameServer", "gameId", _gameServer.gameId ,"roomId", _room.roomId,
            "predId", predId, "preyId", preyId, "preyBloodType", preyBloodType);

        ServerContext.ctrl.doBatch(function () :void {
            for each (var playerId :int in _gameServer.playerIds) {
                if(ServerContext.server.isPlayer(playerId)) {
                    sendPlayerStartGameMsg(playerId);
                }
            }
        });
    }

    protected function sendPlayerStartGameMsg (playerId :int) :void
    {
        if (!ServerContext.server.isPlayer(playerId)) {
            log.error("sendPlayerStartGameMsg, no player", "playerId", playerId);
            return;
        }

        var player :PlayerData = ServerContext.server.getPlayer(playerId);
        //Tell the client lobby to start
        var isPrimPred :Boolean = !prey && _predatorIndex.length == 0;
        var msg :StartFeedingClientMsg = new StartFeedingClientMsg(playerId,
                        _gameServer.gameId, isPrimPred);
        log.debug("Sending start game message to client " + playerId + ", ", "gameId",
            _gameServer.gameId);
        player.sctrl.sendMessage(StartFeedingClientMsg.NAME, msg.toBytes());
        var prey :Boolean = _preyId == playerId;
        log.error("sendPlayerStartGameMsg", "playerId", playerId, "prey", prey, "_predatorIndex", _predatorIndex);

        //Add the predator to the list of predators.  Used for positioning
        if (!prey) {
            if (!ArrayUtil.contains(_predatorIndex, playerId)) {
                _predatorIndex.push(playerId);
            }
            //Tell the pred to move into position
            LogicFeeding.movePredatorIntoPosition(player, this);
            _room.addPlayerToFeedingUnavailableList(playerId);
        }

        if (prey) {
            player.sctrl.setAvatarState(VConstants.AVATAR_STATE_BARED);
        }
    }

    /**
    * If the primary predator has not moved away from behind the prey, send a message to do this.
    */
    protected function movePrimaryPred () :void
    {
        if (_predatorIndex == null || _predatorIndex.length == 0) {
            return;
        }
        var primaryPredatorId :int = _predatorIndex[0] as int;
        //Only move the predator if the room and player are valid

        log.debug("movePrimaryPred", "_primaryPredMoved", _primaryPredMoved, "_room", _room,
            "_room.isPlayer(primaryPredatorId)", _room.isPlayer(primaryPredatorId));//,
//            "_primaryPredInitialLocation", _primaryPredInitialLocation);

        if (!_primaryPredMoved && _room != null && _room.isPlayer(primaryPredatorId)) {
            // && _primaryPredInitialLocation != null

            var primaryPred :PlayerData = _room.getPlayer(primaryPredatorId);

            //If the prey is a non-player, or if a player and they haven't moved, move the pred
            var isPreyPlayer :Boolean = _room.isPlayer(_preyId);
            var isPreyInSameLocation :Boolean = true;
            if (isPreyPlayer) {
                var preyPlayer :PlayerData = _room.getPlayer(_preyId);
                isPreyInSameLocation = ArrayUtil.equals(_preyInitialLocation, preyPlayer.location);
            }

            //If the predator has moved, don't move it again
            var isPredInSameLocation :Boolean = true;
//                ArrayUtil.equals(_primaryPredInitialLocation, primaryPred.location);

            log.debug("isPredInSameLocation=" +isPredInSameLocation);
            log.debug("isPreyInSameLocation=" +isPreyInSameLocation);
            if (isPreyInSameLocation && isPredInSameLocation) {
                primaryPred.sctrl.sendMessage(MovePredAfterFeedingMsg.NAME,
                    new MovePredAfterFeedingMsg().toBytes());
            }

            _primaryPredMoved = true;
        }
    }

    public function onPlayerLeft (playerId :int) :void
    {
        log.debug("onPlayerLeft", "playerId", playerId, "_predatorIndex", _predatorIndex);
        if (_room.isPlayer(playerId)) {
            log.debug("playerLeftCallback", "name", _room.getPlayer(playerId).name);
        }

        if (playerId == _predatorIndex[0]) {
            movePrimaryPred();
        }

        if (_gameServer.playerIds.length == 0 && _gameFinishedCallback != null) {
            _gameFinishedCallback();
            _gameFinishedCallback = null;
        }
        _room.removePlayerToFeedingUnavailableList(playerId);
    }

    public function joinLobby(playerId :int) :void
    {
        if(_gameServer == null) {
            log.error("joinLobby, but","playerId", playerId, "_gameServer", _gameServer, this);
            return;
        }
        if (!ArrayUtil.contains(_gameServer.predatorIds, playerId)) {
            log.debug("joinLobby successful", "playerId", playerId);
            _gameServer.addPredator(playerId);
            sendPlayerStartGameMsg(playerId);
        }
        else {
            log.debug("joinLobby player already exists", "playerId", playerId, "record", this);
        }
    }

    public function onGameStarted () :void
    {
        //Notify the analyser
        if (_room != null) {
            _room.db.sendMessageToNamedObject(new ObjectMessage(AnalyserServer.MSG_RECEIVED_FEED,
                                                                _gameServer.playerIds.slice()),
                                              AnalyserServer.NAME);
        }
    }

    public function onRoundComplete (results :FeedingRoundResults) :void
    {
        try {
            var selfref :FeedingRecord = this;
            ServerContext.server.control.doBatch(function() :void {
                LogicFeeding.bloodBloomRoundOver(selfref, results);
            });
        }
        catch(err :Error) {
            log.error(err.getStackTrace());
        }
    }

    public function onGameComplete () :void
    {
        movePrimaryPred();
    }

    public function get gameId() :int
    {
        return _gameId;
    }

    public function get gameServer() :FeedingServer
    {
        return _gameServer;
    }

    override public function shutdown() :void
    {
        super.shutdown();
        log.debug("shutdown() " + (_gameServer==null ? "Already shutdown...":""));
        if(_room != null && _room.ctrl != null && _room.ctrl.isConnected() &&
            _gameServer != null  && _gameServer.playerIds != null) {

            for each(var gamePlayerId :int in _gameServer.playerIds) {
                _gameServer.playerLeft(gamePlayerId);
                _room.removePlayerToFeedingUnavailableList(gamePlayerId);
            }
        }
        if (_gameServer != null) {
            _gameServer.shutdown();
        }
        _room = null;
        _gameServer = null;
    }

    public function get room() :Room
    {
        return _room;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this)
            + "\n\tpreyId=" + preyId
            + "\n\tprimaryPred=" + _gameServer.primaryPredatorId
            + "\n\tpredIds=" + _gameServer.predatorIds
            + "\n\tplayerIds=" + _gameServer.playerIds
    }

    public function getPredIndex (predId :int) :int
    {
        if (ArrayUtil.contains(_predatorIndex, predId)) {
            return ArrayUtil.indexOf(_predatorIndex, predId);
        }
        return _predatorIndex.length - 1;
    }

    public function get preyId () :int
    {
        return _preyId;
    }

    public function get preyLocation () :Array
    {
        return _preyInitialLocation;
    }

    protected var _room :Room;
    protected var _gameId :int;
    protected var _gameServer :FeedingServer;

    /**
    * If the prey leaves the game, move the primary pred (standing behind her).  But don't move
    * the primary pred on game completion.
    */
    protected var _primaryPredMoved:Boolean = false;

//    protected var _primaryPredInitialLocation :Array;
    protected var _preyInitialLocation :Array;
    protected var _preyId :int;
//    protected var _playerIdsWhenGameStarted :Array;

    protected var _gameFinishedCallback :Function;
    /**
    * A list of predators in the order they request to feed.  Does *not* remove predators
    * that leave and then come back, since they will then stand over other predators.
    */
    protected var _predatorIndex :Array = [];

    protected static const log :Log = Log.getLog(FeedingRecord);

}
}
