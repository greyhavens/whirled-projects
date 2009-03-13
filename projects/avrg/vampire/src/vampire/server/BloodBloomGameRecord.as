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
    import vampire.feeding.FeedingGameServer;

public class BloodBloomGameRecord extends EventCollecter
{
    public function BloodBloomGameRecord( room :Room, gameId :int, predatorId :int, preyId :int,
        multiplePredators :Boolean, preyLocation :Array, gameFinishesCallback :Function)
    {
        _room = room;
        _gameId = gameId;
        _primaryPredatorId = predatorId;
        _predators.add( _primaryPredatorId );
        _preyId = preyId;
        _multiplePredators = multiplePredators;
        _preyLocation = preyLocation;

        if( _multiplePredators ) {
            startCountDownTimer();
        }
        _gameFinishedManagerCallback = gameFinishesCallback;
        _thisBloodBloomRecord = this;

        if( _room != null && _room.ctrl != null ) {
            registerListener(_room.ctrl, AVRGameRoomEvent.PLAYER_LEFT, handlePlayerLeftRoom);
        }
    }

    protected function handlePlayerLeftRoom( e :AVRGameRoomEvent ) :void
    {
        var playerId :int = int(e.value);
        if( _gameServer != null && ArrayUtil.contains(_gameServer.playerIds, playerId)) {
            log.debug("handlePlayerLeftRoom", "playerId", playerId);
            _gameServer.playerLeft( playerId );
        }
    }

    public function startCountDownTimer() :void
    {
        _countdownTimeRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
        _currentCountdownSecond = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
        setCountDownIntoRoomProps();
    }

    public function get isCountDownTimerStarted() :Boolean
    {
        return _countdownTimeRemaining > 0;
    }

    /**
    * Puts into room props
    * array of victim and predator ids, so players not yet in the game can listen
    */
    protected function setCountDownIntoRoomProps() :void
    {
        //Update the countdown timer every whole second.
        var flooredCurrentTime :int = Math.floor( _countdownTimeRemaining );
        if( flooredCurrentTime != _currentCountdownSecond) {

            log.debug("setCountDownIntoRoomProps()", "_currentCountdownSecond", _currentCountdownSecond);
            _currentCountdownSecond = flooredCurrentTime;
            _room.ctrl.sendMessage( VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN, toArray() );
//            _room.ctrl.props.set(Codes.ROOM_PROP_BLOODBLOOM_COUNTDOWN, toArray());
        }
    }

    protected function toArray() :Array
    {
        var result :Array = new Array();
        result.push( _currentCountdownSecond);
        result.push( _preyId );
        result = result.concat( _predators.toArray() );
        return result;
    }

    public static function fromArray( arr :Array ) :BloodBloomGameRecord
    {
        if( arr == null || arr.length < 3 ) {
            log.error("fromArray( " + arr + " )");
            return null;
        }
        var time :int = int(arr[0]);
        var prey :int = int(arr[1]);
        var pred1 :int = int(arr[2]);

        var result :BloodBloomGameRecord = new BloodBloomGameRecord(null, -1, pred1, prey, true, null, null );
        result._currentCountdownSecond = time;

        for( var i :int = 3; i < arr.length; i++) {
            result._predators.add( arr[i] );
        }

        return result;
    }

    public function startGame() :void
    {
        log.debug("startGame()");

        if( _started ) {
            log.error("startGame(), but we have already started...WTF?");
            return;
        }
        _started = true;
        _elapsedGameTime = 0;

        var gamePreyId :int = _room.isPlayer( _preyId ) ? _preyId : 0;

        var preyBlood :Number = _room.isPlayer( _preyId ) ?
            _room.getPlayer( _preyId ).blood / _room.getPlayer( _preyId ).maxBlood
            :
            ServerContext.nonPlayersBloodMonitor.bloodAvailableFromNonPlayer( _preyId ) /
            ServerContext.nonPlayersBloodMonitor.maxBloodFromNonPlayer( _preyId );

        var preyBloodType :int = Logic.getPlayerBloodStrain(_preyId);

        _gameServer = FeedingGameServer.create( _room.roomId,
                                                _predators.toArray(),
                                                gamePreyId,
                                                preyBlood,
                                                preyBloodType,
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
                var pred :Player = ServerContext.vserver.getPlayer( predId );
                if( pred != null ) {
                    pred.actionChange( VConstants.GAME_MODE_NOTHING );
                }
            });
        }

        if( _room != null && _room.getPlayer( primaryPredatorId ) != null ) {
            var primaryPred :Player = _room.getPlayer( primaryPredatorId );
                primaryPred.ctrl.sendMessage( VConstants.NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING );
                _primaryPredMoved = true;
        }

    }

    protected function roundCompleteCallback() :Number
    {
        log.debug("roundCompleteCallback");
        try {
            if( _gameServer != null ) {
                var score :Number = _gameServer.lastRoundScore;
                log.debug("Score=" + score);
                ServerContext.vserver.control.doBatch( function() :void {
                    _room.bloodBloomRoundOver( _thisBloodBloomRecord );
                });

            }
            else {
                log.error("roundCompleteCallback, but gameserver is null, no points!");
            }


            if( _room.isPlayer( _preyId ) ) {
                return _room.getPlayer( _preyId ).blood / _room.getPlayer( _preyId ).maxBlood;
            }
            else {
                return ServerContext.nonPlayersBloodMonitor.bloodAvailableFromNonPlayer( _preyId ) /
                    ServerContext.nonPlayersBloodMonitor.maxBloodFromNonPlayer(_preyId);
            }
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
            if( !_primaryPredMoved && _room != null && _room.getPlayer( primaryPredatorId ) != null ) {
                var primaryPred :Player = _room.getPlayer( primaryPredatorId );
                primaryPred.ctrl.sendMessage( VConstants.NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING );
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

    public function isPredator( playerId :int ) :Boolean
    {
        log.debug("isPredator(" +  playerId + "), _predators=" + _predators.toArray());
        log.debug("  returning " + _predators.contains( playerId ));
        return _predators.contains( playerId );
    }

    public function isPrey( playerId :int ) :Boolean
    {
        return playerId == _preyId;
    }

    public function removePlayer ( playerId :int ) :void
    {
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

    public function update( dt :Number ) :void
    {
        if( !_started && _multiplePredators) {
            _countdownTimeRemaining -= dt;

            if( _countdownTimeRemaining <= 0 ) {
                setCountDownIntoRoomProps();
                startGame();
            }
            else {
                setCountDownIntoRoomProps();
            }
        }

//        if( _started ) {
//            _elapsedGameTime += dt;
//
//            if( _elapsedGameTime > vampire.feeding.Constants.GAME_TIME + 10 ) {
//                log.error("Game is still running 10 secs after it should of shutdown.  _shutdown=true");
//                _finished = true;
//            }
//        }
    }

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

    public function get gameServer() :FeedingGameServer
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
    public function get currentCountDownSecond() :int
    {
        return _currentCountdownSecond;
    }

    public function get multiplePredators() :Boolean
    {
        return _multiplePredators;
    }

    public function get preyLocation() :Array
    {
        return _preyLocation;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this)
            + " _preyId=" + _preyId
            + " _predators=" + _predators.toArray()
            + " _multiplePredators=" + _multiplePredators
            + " _primaryPredatorId=" + _primaryPredatorId
            + " _countdownTimeRemaining=" + _countdownTimeRemaining
            + " _started=" + _started
            + " _finished=" + _finished
            + " _elapsedGameTime=" + _elapsedGameTime
            + "lastRoundScore=" + (_gameServer != null ? _gameServer.lastRoundScore : 0)
    }






    protected var _room :Room;
    protected var _gameId :int;

    protected var _gameServer :FeedingGameServer;

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
    protected var _multiplePredators :Boolean;
    protected var _countdownTimeRemaining :Number = 0;
    protected var _currentCountdownSecond :int;
    protected var _elapsedGameTime :Number = 0;
    protected var _gameFinishedManagerCallback :Function;
    protected var _thisBloodBloomRecord :BloodBloomGameRecord;

    protected static const log :Log = Log.getLog( BloodBloomGameRecord );

}
}
