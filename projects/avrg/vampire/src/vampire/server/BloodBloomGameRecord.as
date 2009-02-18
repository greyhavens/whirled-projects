package vampire.server
{
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    
    import vampire.feeding.FeedingGameServer;
    
public class BloodBloomGameRecord
{
    public function BloodBloomGameRecord( room :Room, gameId :int, predatorId :int, preyId :int, multiplePredators :Boolean)
    {
        _room = room;
        _gameId = gameId;
        primaryPredator = predatorId;
        predators.add( primaryPredator );
        prey = preyId;
        _multiplePredators = multiplePredators
    }
    
    public function startGame() :void
    {
        _gameServer = FeedingGameServer.create( _room.roomId, predators.toArray(), prey, gameFinishedCallback);
        
        // send a message with the game ID to each of the players, and store the
        // playerIds in a map
        ServerContext.ctrl.doBatch(function () :void {
            for each (var playerId :int in playerIds) {
//                _playerGameMap.put(playerId, game);
                ServerContext.ctrl.getPlayer(playerId).sendMessage("StartClient", _gameServer.gameId);
            }
        });
        
        
        _started = true;
    }
    
    protected function gameFinishedCallback() :void
    {
        log.debug("Game finished");
        log.debug("_gameServer.finalScore=" + _gameServer);
        _finished = true;
        
    }
    
    public function addPredator( playerId :int ) :void
    {
        predators.add( playerId );
    }
    
    public function isPredator( playerId :int ) :Boolean
    {
        return predators.contains( playerId );
    }
    
    public function isPrey( playerId :int ) :Boolean
    {
        return playerId == prey;
    }
    
    public function update( dt :Number ) :void
    {
        
    }
    
    public function get isStarted() :Boolean
    {
        return _started;
    }
    
    public function get isFinished() :Boolean
    {
        return _started;
    }
    
    public function setFinished( finished :Boolean) :void
    {
        _finished = finished;
    }

    
    
    
    public function get gameId() :int
    {
        return _gameId;
    }
    
    public function get playerIds() :Array
    {
        return predators.toArray().concat([prey]);
    }
    
    public function get gameServer() :FeedingGameServer
    {
        return _gameServer;
    }
    
    public function shutdown() :void
    {
        _room = null;
        _gameServer = null;
    }
    
    
    
    
    protected var _room :Room;
    protected var _gameId :int;
    
    protected var _gameServer :FeedingGameServer;
    
    public var predators :HashSet = new HashSet();
    public var prey :int;
    public var primaryPredator :int;
    protected  var _started :Boolean = false;
    protected  var _finished :Boolean = false;
    protected  var _multiplePredators :Boolean;
    
    protected var log :Log = Log.getLog( BloodBloomGameRecord );

}
}