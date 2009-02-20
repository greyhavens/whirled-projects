package vampire.server
{
    import com.threerings.util.ClassUtil;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    
    import vampire.data.VConstants;
    import vampire.feeding.FeedingGameServer;
    
public class BloodBloomGameRecord
{
    public function BloodBloomGameRecord( room :Room, gameId :int, predatorId :int, preyId :int, multiplePredators :Boolean)
    {
        _room = room;
        _gameId = gameId;
        _primaryPredatorId = predatorId;
        _predators.add( _primaryPredatorId );
        _preyId = preyId;
        _multiplePredators = multiplePredators;
        
        if( _multiplePredators ) {
            startCountDownTimer();
        }
    }
    
    protected function startCountDownTimer() :void
    {
        _countdownTimeRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
        _currentCountdownSecond = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
        setCountDownIntoRoomProps();
    }
    
    /**
    * Puts into room props
    * array of victim and predator ids, so players not yet in the game can listen
    */
    protected function setCountDownIntoRoomProps() :void
    {
        //Update the countdown timer wvery whole second.
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
        
        var result :BloodBloomGameRecord = new BloodBloomGameRecord(null, -1, pred1, prey, true );
        
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
        
        _elapsedGameTime = 0;
        
        var gamePreyId :int = _room.isPlayer( _preyId ) ? _preyId : -1;
        
        var preyBlood :Number = _room.isPlayer( _preyId ) ? _room.getPlayer( _preyId ).blood :
            ServerContext.nonPlayersBloodMonitor.bloodAvailableFromNonPlayer( _preyId );
        
        _gameServer = FeedingGameServer.create( _room.roomId, 
                                                _predators.toArray(), 
                                                gamePreyId,
                                                preyBlood,
                                                roundFinishedCallback,
                                                gameFinishedCallback);
                                                 
        log.debug("starting gameServer", "gameId", _gameServer.gameId ,"roomId", _room.roomId, "_predators", _predators.toArray(), "gamePreyId", gamePreyId);
        
        // send a message with the game ID to each of the players, a
        ServerContext.ctrl.doBatch(function () :void {
            for each (var playerId :int in playerIds) {
                if( _room.isPlayer( playerId )) {
                    _room.getPlayer( playerId ).ctrl.sendMessage("StartClient", _gameServer.gameId);
//                    ServerContext.ctrl.getPlayer(playerId).sendMessage("StartClient", _gameServer.gameId);
                }
            }
        });
        
        
        _started = true;
    }
    
    protected function gameFinishedCallback(...ignored) :void
    {
        log.debug("gameFinishedCallback");
        
        if( _gameServer != null ) {
            var score :Number = _gameServer.lastRoundScore;
            log.debug("Score=" + score);
            
        }
        else {
            log.error("gameFinishedCallback, but gameserver is null, no points!");
        }
//        log.debug("_gameServer.finalScore=" + _gameServer.finalScore);
//        log.debug("_gameServer.playerIds=" + _gameServer.playerIds);
        shutdown();
    }
    
    protected function roundFinishedCallback(...ignored) :void
    {
        log.debug("roundFinishedCallback, for now quit game");
//        log.debug("_gameServer.finalScore=" + _gameServer.finalScore);
//        log.debug("_gameServer.playerIds=" + _gameServer.playerIds);
        shutdown();
    }
    
    public function addPredator( playerId :int ) :void
    {
        _predators.add( playerId );
    }
    
    public function isPredator( playerId :int ) :Boolean
    {
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
                startGame();
            }
            else {
                setCountDownIntoRoomProps();
            }
        }
        
        if( _started ) {
            _elapsedGameTime += dt;
            
            if( _elapsedGameTime > vampire.feeding.Constants.GAME_TIME + 10 ) {
                log.error("Game is still running 10 secs after it should of shutdown.  _shutdown=true");
                _finished = true;
            }
        }
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
    
    public function get playerIds() :Array
    {
        return _predators.toArray().concat([_preyId]);
    }
    
    public function get gameServer() :FeedingGameServer
    {
        return _gameServer;
    }
    
    public function shutdown() :void
    {
        log.debug("shutdown() " + (_gameServer==null ? "Already shutdown...":""));
        if( _gameServer != null  && _gameServer.playerIds != null) {
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
    
    public function toString() :String
    {
        return ClassUtil.tinyClassName(this) 
            + " _preyId=" + _preyId
            + "_predators=" + _predators.toArray()
            + "_primaryPredatorId=" + _primaryPredatorId
            + "_currentCountdownSecond=" + _currentCountdownSecond
            + "_started=" + _started
            + "_finished=" + _finished
    }
    
    
    protected var _room :Room;
    protected var _gameId :int;
    
    protected var _gameServer :FeedingGameServer;
    
    protected var _predators :HashSet = new HashSet();
    protected var _preyId :int;
    protected var _primaryPredatorId :int;
    protected var _started :Boolean = false;
    protected var _finished :Boolean = false;
    protected var _multiplePredators :Boolean;
    protected var _countdownTimeRemaining :Number;
    protected var _currentCountdownSecond :int;
    protected var _elapsedGameTime :Number;
    
    protected static const log :Log = Log.getLog( BloodBloomGameRecord );

}
}