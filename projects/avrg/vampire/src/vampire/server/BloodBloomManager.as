package vampire.server
{
    import com.threerings.util.ClassUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.server.SimObjectThane;
    
    import vampire.data.VConstants;
    
public class BloodBloomManager extends SimObjectThane
{
    public function BloodBloomManager( room :Room )
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
    
    public function requestFeed( predatorId :int, preyId :int, multiplePredators :Boolean, preyLocation :Array ) :BloodBloomGameRecord
    {
        log.debug("begin requestFeed ", "predatorId", predatorId, "preyId", preyId, 
            "multiplePredators", multiplePredators, "BloodBloomManager", this);
        
        var currentGame :BloodBloomGameRecord = _playerId2Game.get( predatorId ) as BloodBloomGameRecord;
        if( currentGame != null ) {
            if( currentGame.preyId == preyId ) {
                log.debug(predatorId + " doing nothing, prey is already in a game I am also in. Game=" + currentGame);        
            }
            else {
                currentGame.removePlayer( predatorId );
                _playerId2Game.remove( predatorId );
                log.debug(predatorId + "  I am alrady in a game with a different prey, so leaving that game. Game=" + currentGame);
            }
        }
        
        
        if( _playerId2Game.containsKey( preyId ) ) {
            log.debug(predatorId + " requestFeed, adding to existing game");
            var gameRecord :BloodBloomGameRecord = _playerId2Game.get( preyId ) as BloodBloomGameRecord;
            if( !gameRecord.isStarted ) {
                gameRecord.addPredator( predatorId, preyLocation );
                _playerId2Game.put( predatorId, gameRecord );
            }
            return gameRecord;
        }
        else {
            log.debug(predatorId + " requestFeed, creating a new game");
            return createNewBloodBloomGameRecord( predatorId, preyId, multiplePredators, preyLocation );
        }
    }
    
    protected function gameFinishedCallback( record :BloodBloomGameRecord ) :void
    {
        for each( var playerId :int in record.playerIds ) {
            _playerId2Game.remove( playerId );
        }
    }
    
    override protected function update( dt :Number ) :void
    {
        
        for each( var game :BloodBloomGameRecord in _games ) {
            game.update( dt );
        }
        removeFinishedGames();
    }
    
    protected function removeFinishedGames() :void
    {
        var index :int = 0;
        while( index < _games.length) {
            var gameRecord :BloodBloomGameRecord = _games[index] as BloodBloomGameRecord;
            if( gameRecord != null && gameRecord.isFinished ) {
                log.debug("Removing finished BloodBloomGameRecord");
                _games.splice( index, 1);
                gameRecord.predators.forEach( function( predatorId :int) :void {
                    if( _playerId2Game.get(predatorId) == gameRecord) {
                        _playerId2Game.remove( predatorId );
                    }
                });
                
                //Set the avatars to the default state after a game.
                for each( var playerId :int in gameRecord.playerIds) {
                    if( _room.isPlayer( playerId ) ) {
                        _room.getPlayer( playerId ).actionChange( VConstants.GAME_MODE_NOTHING );
                    }
                }
                
                _playerId2Game.remove( gameRecord.preyId );
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
            _playerId2Game.remove( playerId );
        }
    }
    
    public function isPredatorInGame( playerId :int ) :Boolean
    {
        if( !_playerId2Game.containsKey( playerId )) {
            log.debug("isPredatorInGame(" + playerId + "), but no key in _playerId2Game, _playerId2Game.keys=" + _playerId2Game.keys());
            return false;
        }
        
        var game :BloodBloomGameRecord = _playerId2Game.get( playerId ) as BloodBloomGameRecord;
        
        var isPredator :Boolean = game.isPredator( playerId );
        log.debug("isPredatorInGame(" + playerId + ") returning " + isPredator);
        return isPredator;
    }
    
    public function isPreyInGame( playerId :int ) :Boolean
    {
        if( !_playerId2Game.containsKey( playerId )) {
            return false;
        }
        
        var game :BloodBloomGameRecord = _playerId2Game.get( playerId ) as BloodBloomGameRecord;
        return game.isPrey( playerId );
    }
    
    public function getGame( playerId :int ) :BloodBloomGameRecord 
    {
        if( !_playerId2Game.containsKey( playerId )) {
            log.debug("getGame(" + playerId + "), but us=" + toString());
            return null;
        }
        
        return _playerId2Game.get( playerId ) as BloodBloomGameRecord;    
    }
    
    
    protected function createNewBloodBloomGameRecord( predatorId :int, preyId :int, 
        multiplePredators :Boolean, preyLocation :Array ) :BloodBloomGameRecord
    {
        log.debug("createNewBloodBloomGameRecord ", "predatorId", predatorId, "preyId", preyId, "multiplePredators", multiplePredators);
        var gameRecord :BloodBloomGameRecord = new BloodBloomGameRecord( _room, 
            nextBloodBloomGameId, predatorId, preyId, multiplePredators, preyLocation, 
            gameFinishedCallback);
        _playerId2Game.put( predatorId, gameRecord );
        _playerId2Game.put( preyId, gameRecord );
        _games.push( gameRecord );
        
//        if( !multiplePredators ) {
//            gameRecord.startGame();
//        }
        return gameRecord;
    }
    
    override public function toString() :String
    {
        return ClassUtil.tinyClassName( this ) 
            + "\n _games.length=" + _games.length
            + "\n _playerId2Game.size()=" + _playerId2Game.size()
            + "\n _playerId2Game.keys()=" + _playerId2Game.keys()
            + "\n games listed:\n  " + _games.join("\n  ")
    }
    
    protected var _room :Room;
    protected var _playerId2Game :HashMap = new HashMap();
    protected var _games :Array = new Array();
    protected var _bloodBloomIdCounter :int = 0;
    
    protected static const log :Log = Log.getLog( BloodBloomManager );
}
}