package vampire.server
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.simplegame.EventCollecter;

import vampire.data.Logic;
import vampire.data.VConstants;
import vampire.feeding.FeedingServer;

public class FeedingRecord extends EventCollecter
{
    public function FeedingRecord( room :Room, gameId :int, predatorId :int, preyId :int,
        preyLocation :Array, gameFinishesCallback :Function)
    {
        _room = room;
        _gameId = gameId;
        _primaryPredatorId = predatorId;
        _predators.add( _primaryPredatorId );
        _preyId = preyId;
        _preyLocation = preyLocation;

        _gameFinishedManagerCallback = gameFinishesCallback;
        _thisBloodBloomRecord = this;//For referencing in enclosed functions.

        if (_room != null && _room.ctrl != null) {
            registerListener(_room.ctrl, AVRGameRoomEvent.PLAYER_LEFT, handlePlayerLeftRoom);
        }
    }

    protected function handlePlayerLeftRoom (e :AVRGameRoomEvent) :void
    {
        var playerId :int = int(e.value);
        playerLeavesGame(playerId);
    }

    public function playerLeavesGame (playerId :int, moved :Boolean = false ) :void
    {
        if (moved && _primaryPredatorId == playerId) {
            _primaryPredMoved = true;
        }

        if (_gameServer != null && ArrayUtil.contains(_gameServer.playerIds, playerId)) {
            log.debug("handlePlayerLeftRoom", "playerId", playerId);
            _gameServer.playerLeft( playerId );
        }
    }

    public function get isLobbyStarted () :Boolean
    {
        return _gameServer != null && _started == false;
    }
    public function startLobby() :void
    {
        log.debug("startGame()");

        if( _started ) {
            log.error("startGame(), but we have already started...WTF?");
            return;
        }
        _started = true;
//        _elapsedGameTime = 0;

        var gamePreyId :int = _room.isPlayer( _preyId ) ? _preyId : 0;


        //We have disabled blood, until the game gets more interesting.
        var preyBlood :Number = 1.0;
//        var preyBlood :Number = _room.isPlayer( _preyId ) ?
//            _room.getPlayer( _preyId ).blood / _room.getPlayer( _preyId ).maxBlood
//            :
//            ServerContext.npBlood.bloodAvailableFromNonPlayer( _preyId ) /
//            ServerContext.npBlood.maxBloodFromNonPlayer( _preyId );

        var preyBloodType :int = Logic.getPlayerBloodStrain(_preyId);

        // TODO: fix this
        var predatorId :int = _primaryPredatorId;//_predators.toArray()[0];

        _gameServer = FeedingServer.create( _room.roomId,
                                                predatorId,
                                                gamePreyId,
                                                preyBlood,
                                                preyBloodType,
                                                gameStartedCallback,
                                                roundCompleteCallback,
                                                gameFinishedCallback,
                                                playerLeftCallback);

        log.debug("starting gameServer", "gameId", _gameServer.gameId ,"roomId", _room.roomId, "_predators", _predators.toArray(), "gamePreyId", gamePreyId);

        // send a message with the game ID to each of the players, a
        ServerContext.ctrl.doBatch(function () :void {
            for each (var playerId :int in playerIds) {
                if( _room.isPlayer( playerId )) {
                    log.debug("Sending start game message to client " + playerId + "=StartClient", _gameServer.gameId);
                    _room.getPlayer( playerId ).ctrl.sendMessage("StartClient", _gameServer.gameId);
//                    ServerContext.ctrl.getPlayer(playerId).sendMessage("StartClient", _gameServer.gameId);
                }
            }
        });



    }

    protected function playerLeftCallback( playerId :int ) :void
    {
        //Force all predator avatars out of the feeding state
        if( playerId == _preyId ) {
            _predators.forEach( function( predId :int ) :void {
                var pred :PlayerData = ServerContext.server.getPlayer( predId );
                if( pred != null ) {
                    ServerLogic.stateChange( pred, VConstants.PLAYER_STATE_DEFAULT );
//                    pred.actionChange( VConstants.GAME_MODE_NOTHING );
                }
            });

            if( _room != null && _room.getPlayer( primaryPredatorId ) != null ) {
                var primaryPred :PlayerData = _room.getPlayer( primaryPredatorId );
                    primaryPred.ctrl.sendMessage(
                        VConstants.NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING );
                    _primaryPredMoved = true;
            }
        }
    }

    public function joinLobby( playerId :int ) :void
    {
        if( _gameServer == null) {
            log.error("joinLobby, but gameserver is null","playerId", playerId);
            return;
        }

        _gameServer.addPredator( playerId );
        _predators.add( playerId );

        log.debug("Sending start game message to client " + playerId + "=StartClient",
            _gameServer.gameId);
        _room.getPlayer( playerId ).ctrl.sendMessage("StartClient", _gameServer.gameId);
    }

    protected function gameStartedCallback () :void
    {
        _started = true;

        _gameServer.predatorIds.forEach( function(playerId :int, ...ignored) :void {
            var player :PlayerData = _room.getPlayer(playerId);
            if (player != null) {
                ServerLogic.stateChange(player, VConstants.PLAYER_STATE_FEEDING_PREDATOR);
            }
        });

        var prey :PlayerData = _room.getPlayer(_gameServer.preyId);
        if (prey != null) {
            ServerLogic.stateChange(prey, VConstants.PLAYER_STATE_FEEDING_PREY);
        }
    }

    protected function roundCompleteCallback() :Number
    {
        log.debug("roundCompleteCallback");
        try {
            if( _gameServer != null ) {
                var score :Number = _gameServer.lastRoundScore;
                log.debug("Score=" + score);
                ServerContext.server.control.doBatch( function() :void {
                    ServerLogic.bloodBloomRoundOver( _thisBloodBloomRecord );
//                    _room.bloodBloomRoundOver( _thisBloodBloomRecord );
                });

            }
            else {
                log.error("roundCompleteCallback, but gameserver is null, no points!");
            }

            //For the moment we don't record the amount of blood in anyone.
//            if( _room.isPlayer( _preyId ) ) {
//                return _room.getPlayer( _preyId ).blood / _room.getPlayer( _preyId ).maxBlood;
//            }
//            else {
//                return ServerContext.npBlood.bloodAvailableFromNonPlayer( _preyId ) /
//                    ServerContext.npBlood.maxBloodFromNonPlayer(_preyId);
//            }
            return 1;
        }
        catch( err :Error ) {
            log.error(err.getStackTrace());
            trace(err.getStackTrace());
        }
        return 0;
    }

    protected function gameFinishedCallback(...ignored) :void
    {
        try {

            //The prey steps away from the predator, if the predator
            if (!_primaryPredMoved && _room != null
                && _room.getPlayer( primaryPredatorId ) != null) {
                var primaryPred :PlayerData = _room.getPlayer( primaryPredatorId );
                primaryPred.ctrl.sendMessage( VConstants.NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING );
            }
            if (_gameServer != null) {
//                _gameServer.shutdown();
            }
            log.debug("gameFinishedCallback");
            shutdown();
            _gameFinishedManagerCallback(this);
        }
        catch( err :Error ) {
            log.error(err.getStackTrace());
        }
    }


    public function addPredator( playerId :int, preyLocation :Array ) :void
    {
        _predators.add( playerId );
        _preyLocation = preyLocation;
    }

    public function isPredator (playerId :int) :Boolean
    {
        return _predators.contains( playerId );
    }

    public function isPrey (playerId :int) :Boolean
    {
        return playerId == _preyId;
    }

    public function removePlayer (playerId :int) :void
    {
        if( !_started ) {
        }
        else {
            if( _preyId == playerId ) {
                log.info("Shutting down bloodbloom game because prey removed");
                shutdown();
            }
            else {
                _predators.remove( playerId );
                if( _gameServer != null ) {
                    if(_gameServer.playerLeft( playerId ) ) {
                        shutdown();
                    }
                }
                if( _predators.size() == 0) {
                    log.info("Shutting down bloodbloom game because pred==0");
                    shutdown();
                }
            }

        }
    }

//    public function update( dt :Number ) :void
//    {
//        if( !_started && _multiplePredators) {
//            _countdownTimeRemaining -= dt;
//
//            if( _countdownTimeRemaining <= 0 ) {
//                setCountDownIntoRoomProps();
//                startGame();
//            }
//            else {
//                setCountDownIntoRoomProps();
//            }
//        }
//
////        if( _started ) {
////            _elapsedGameTime += dt;
////
////            if( _elapsedGameTime > vampire.feeding.Constants.GAME_TIME + 10 ) {
////                log.error("Game is still running 10 secs after it should of shutdown.  _shutdown=true");
////                _finished = true;
////            }
////        }
//    }

    public function get isStarted() :Boolean
    {
        return _started;
    }

    public function get isFinished() :Boolean
    {
        return _finished;
    }

    protected function setFinished( finished :Boolean) :void
    {
        _finished = finished;
    }




    public function get gameId() :int
    {
        return _gameId;
    }

    public function get primaryPredatorId() :int
    {
        return _primaryPredatorId;
    }

    public function get playerIds() :Array
    {
        return _predators.toArray().concat([_preyId]);
    }

    public function get gameServer() :FeedingServer
    {
        return _gameServer;
    }

    override public function shutdown() :void
    {
        super.shutdown();
        log.debug("shutdown() " + (_gameServer==null ? "Already shutdown...":""));
        if( _room != null && _room.ctrl != null && _room.ctrl.isConnected() &&
            _gameServer != null  && _gameServer.playerIds != null) {

            for each( var gamePlayerId :int in _gameServer.playerIds ) {
                _gameServer.playerLeft( gamePlayerId );
            }
        }
        _room = null;
        _gameServer = null;

        _finished = true;
    }

    public function get preyId () :int
    {
        return _preyId;
    }

    public function get predators() :HashSet
    {
        return _predators;
    }
//    public function get currentCountDownSecond() :int
//    {
//        return _currentCountdownSecond;
//    }

//    public function get multiplePredators() :Boolean
//    {
//        return _multiplePredators;
//    }

    public function get preyLocation() :Array
    {
        return _preyLocation;
    }

    public function get room() :Room
    {
        return _room;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this)
            + " _preyId=" + _preyId
            + " _predators=" + _predators.toArray()
//            + " _multiplePredators=" + _multiplePredators
            + " _primaryPredatorId=" + _primaryPredatorId
            + " _started=" + _started
            + " _finished=" + _finished
//            + " _elapsedGameTime=" + _elapsedGameTime
//            + "lastRoundScore=" + (_gameServer != null ? _gameServer.lastRoundScore : 0)
    }






    protected var _room :Room;
    protected var _gameId :int;

    protected var _gameServer :FeedingServer;

    protected var _predators :HashSet = new HashSet();
    protected var _preyId :int;
    protected var _preyLocation :Array;
    protected var _primaryPredatorId :int;
    protected var _started :Boolean = false;
    protected var _finished :Boolean = false;
    /**
    * If the prey leaves the game, move the primary pred (standing behind her).  But don't move
    * the primary pred on game completion.
    */
    protected var _primaryPredMoved:Boolean = false;
//    protected var _multiplePredators :Boolean;
//    protected var _countdownTimeRemaining :Number = 0;
//    protected var _currentCountdownSecond :int;
//    protected var _elapsedGameTime :Number = 0;
    protected var _gameFinishedManagerCallback :Function;
    protected var _thisBloodBloomRecord :FeedingRecord;

    protected static const log :Log = Log.getLog( FeedingRecord );

}
}
