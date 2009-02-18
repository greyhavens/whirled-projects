package vampire.server
{
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.server.SimObjectThane;
    
public class BloomBloomManager extends SimObjectThane
{
    public function BloomBloomManager( room :Room )
    {
        _room = room;
        
    }
    
    override protected function destroyed () :void
    {
        var gamesShutdown :HashSet = new HashSet();
        _playerId2Game.forEach( function( playerId :int, game :BloodBloomGameRecord) :void {
            if( !gamesShutdown.contains( game.gameServer.gameId ) ) {
                gamesShutdown.add( game.gameServer.gameId );
                game.shutdown();
            }
        });
        _playerId2Game.clear();
        _games.splice(0);
        _room = null;
    }
    
    public function predatorBeginsGame( predatorId :int ) :void
    {
        var gameRecord :BloodBloomGameRecord = _playerId2Game.get( predatorId ) as BloodBloomGameRecord;
        if( gameRecord != null) {
            log.debug("predatorBeginsGame ", "predatorId", predatorId);
            gameRecord.startGame();
        }
        else {
            log.debug("predatorBeginsGame, but no game for that record", "predatorId", predatorId);
        }
    }
    
    protected function get nextBloodBloomGameId() :int 
    {
        return ++_bloodBloomIdCounter;
    }
    
    public function requestFeed( predatorId :int, preyId :int, multiplePredators :Boolean ) :void
    {
        if( _playerId2Game.containsKey( preyId ) ) {
            var gameRecord :BloodBloomGameRecord = _playerId2Game.get( preyId ) as BloodBloomGameRecord;
            gameRecord.addPredator( predatorId );
        }
        else {
            createNewBloodBloomGameRecord( predatorId, preyId, multiplePredators );
        }
    }
    
    override protected function update( dt :Number ) :void
    {
        removeFinishedGames();
        
        for each( var game :BloodBloomGameRecord in _games ) {
            game.update( dt );
        }
    }
    
    protected function removeFinishedGames() :void
    {
        var index :int = 0;
        while( index < _games.length) {
            var gameRecord :BloodBloomGameRecord = _games[index] as BloodBloomGameRecord;
            if( gameRecord.isFinished ) {
                log.debug("Removing finished BloodBloomGameRecord");
                _games.splice( index, 1);
                gameRecord._predators.forEach( function( predatorId :int) :void {
                    if( _playerId2Game.get(predatorId) == gameRecord) {
                        _playerId2Game.remove( predatorId );
                    }
                    
                });
                _playerId2Game.remove( gameRecord._preyId );
                gameRecord.shutdown();
            }
            else {
                index++;
            }
        }
    }
    
    public function playerQuitsGame( playerId :int ) :void
    {
        if( _playerId2Game.containsKey( playerId ) ) {
            var gameRecord :BloodBloomGameRecord = _playerId2Game.get( playerId ) as BloodBloomGameRecord;
            gameRecord.removePlayer( playerId );
            removeFinishedGames();
        }
    }
    
    
    protected function createNewBloodBloomGameRecord( predatorId :int, preyId :int, multiplePredators :Boolean ) :void
    {
        log.debug("createNewBloodBloomGameRecord ", "predatorId", predatorId, "preyId", preyId);
        var gameRecord :BloodBloomGameRecord = new BloodBloomGameRecord( _room, nextBloodBloomGameId, predatorId, preyId, multiplePredators);
        _playerId2Game.put( predatorId, gameRecord );
        _playerId2Game.put( preyId, gameRecord );
        _games.push( gameRecord );
        
        if( !multiplePredators ) {
            gameRecord.startGame();
        }
    }
    
    protected var _room :Room;
    protected var _playerId2Game :HashMap = new HashMap();
    protected var _games :Array = new Array();
    protected var _bloodBloomIdCounter :int = 0;
    
    protected static const log :Log = Log.getLog( BloomBloomManager );
}
}