package vampire.server
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.EventCollecter;
import com.whirled.contrib.simplegame.ObjectMessage;

import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.Constants;
import vampire.feeding.FeedingHost;
import vampire.feeding.FeedingServer;
import vampire.feeding.variant.Variant;
import vampire.net.messages.MovePredAfterFeedingMsg;
import vampire.net.messages.StartFeedingClientMsg;

public class FeedingRecord extends EventCollecter
    implements FeedingHost
{
    public function FeedingRecord(room :Room,
                                   gameId :int,
                                   predatorId :int,
                                   preyId :int,
                                   preyName :String,
                                   preyLocation :Array)
    {
        _room = room;
        _gameId = gameId;
        _preyId = preyId;
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
        if (moved && _gameServer.primaryPredatorId == playerId || _gameServer.preyId == playerId) {
            _primaryPredMoved = true;
        }

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

        log.debug("starting gameServer", "gameId", _gameServer.gameId ,"roomId", _room.roomId, "predId", predId, "gamePreyId", gamePreyId);

        ServerContext.ctrl.doBatch(function () :void {
            for each (var playerId :int in _gameServer.playerIds) {
                if(ServerContext.server.isPlayer(playerId)) {
                    log.debug("Sending start game message to client " + playerId + "=StartClient", _gameServer.gameId);
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

        var msg :StartFeedingClientMsg = new StartFeedingClientMsg(playerId,
                        _gameServer.gameId);
        log.debug("Sending start game message to client " + playerId + ", ", "gameId",
            _gameServer.gameId);
        var player :PlayerData = ServerContext.server.getPlayer(playerId);
        player.sctrl.sendMessage(
            StartFeedingClientMsg.NAME, msg.toBytes());

        var prey :Boolean = _gameServer.preyId == playerId;

        if (!prey && !ArrayUtil.contains(_predatorIndex, playerId)) {
            _predatorIndex.push(playerId);
        }

        ServerLogic.stateChange(player, prey ? VConstants.PLAYER_STATE_FEEDING_PREY :
            VConstants.PLAYER_STATE_FEEDING_PREDATOR);
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
        if (!_primaryPredMoved && _room != null && _room.isPlayer(primaryPredatorId)
            && _primaryPredInitialLocation != null) {

            var primaryPred :PlayerData = _room.getPlayer(primaryPredatorId);

            //If the prey is a non-player, or if a player and they haven't moved, move the pred
            var isPreyPlayer :Boolean = _room.isPlayer(_preyId);
            var isPreyInSameLocation :Boolean = true;
            if (isPreyPlayer) {
                var preyPlayer :PlayerData = _room.getPlayer(_preyId);
                isPreyInSameLocation = ArrayUtil.equals(_preyInitialLocation, preyPlayer.location);
            }

            //If the predator has moved, don't move it again
            var isPredInSameLocation :Boolean =
                ArrayUtil.equals(_primaryPredInitialLocation, primaryPred.location);


            if (isPreyInSameLocation && isPredInSameLocation) {
                primaryPred.sctrl.sendMessage(MovePredAfterFeedingMsg.NAME,
                    new MovePredAfterFeedingMsg().toBytes());
            }

            _primaryPredMoved = true;
        }
    }

    public function onPlayerLeft (playerId :int) :void
    {
        if (_room.isPlayer(playerId)) {
            log.debug("playerLeftCallback", "name", _room.getPlayer(playerId).name);
        }

        if (_room != null && _room.isPlayer(playerId)) {
            ServerLogic.stateChange(_room.getPlayer(playerId), VConstants.PLAYER_STATE_DEFAULT);
        }

        //Force all predator avatars out of the feeding state
//        if (playerId == _gameServer.preyId) {
//
//            for each (var predId :int in _gameServer.predatorIds) {
//                if (ServerContext.server.isPlayer(predId)) {
//                    var pred :PlayerData = ServerContext.server.getPlayer(predId);
//                    ServerLogic.stateChange(pred, VConstants.PLAYER_STATE_DEFAULT);
//                }
//            }
//
//            if(_room != null && _room.isPlayer(_gameServer.primaryPredatorId)) {
//                movePrimaryPred();
//            }
//        }
//        else
        if (playerId == _predatorIndex[0]) {
            movePrimaryPred();
        }
    }

    public function joinLobby(playerId :int) :void
    {
        if(_gameServer == null) {
            log.error("joinLobby, but gameserver is null","playerId", playerId);
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

        if (ServerContext.server.isPlayer(_gameServer.preyId)) {
            _preyInitialLocation = ServerContext.server.getPlayer(_gameServer.preyId).location;
        }
        if (ServerContext.server.isPlayer(_predatorIndex[0])) {
            _primaryPredInitialLocation = ServerContext.server.getPlayer(_predatorIndex[0]).location;
        }
    }

    public function onRoundComplete (finalScores :HashMap) :void
    {
        log.debug("roundCompleteCallback");
        try {
            if(_gameServer != null) {

                var score :Number = _gameServer.lastRoundScore;
                log.debug("Score=" + score);
                var selfref :FeedingRecord = this;
                ServerContext.server.control.doBatch(function() :void {
                    ServerLogic.bloodBloomRoundOver(selfref, finalScores);
                });

            }
            else {
                log.error("roundCompleteCallback, but gameserver is null, no points!");
            }
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
            + "\n\tpreyId=" + _gameServer.preyId
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

    protected var _room :Room;
    protected var _gameId :int;
    protected var _gameServer :FeedingServer;

    /**
    * If the prey leaves the game, move the primary pred (standing behind her).  But don't move
    * the primary pred on game completion.
    */
    protected var _primaryPredMoved:Boolean = false;

    protected var _primaryPredInitialLocation :Array;
    protected var _preyInitialLocation :Array;
    protected var _preyId :int;

    /**
    * A list of predators in the order they request to feed.  Does *not* remove predators
    * that leave and then come back, since they will then stand over other predators.
    */
    protected var _predatorIndex :Array = [];

    protected static const log :Log = Log.getLog(FeedingRecord);

}
}
