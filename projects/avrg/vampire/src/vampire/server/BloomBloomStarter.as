package vampire.server
{
    import com.threerings.util.HashMap;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.Updatable;
    
public class BloomBloomStarter 
    implements Updatable
{
    public function BloomBloomStarter( room :Room )
    {
        _room = room;
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
    
    public function requestFeed( predatorId :int, preyId :int ) :void
    {
        if( _playerId2Game.containsKey( preyId ) ) {
            var gameRecord :BloodBloomGameRecord = _playerId2Game.get( preyId ) as BloodBloomGameRecord;
            gameRecord.addPredator( predatorId );
        }
        else {
            createNewBloodBloomGameRecord( predatorId, preyId );
        }
    }
    
    public function update( dt :Number ) :void
    {
        var index :int = 0;
        while( index < _games.length) {
            var gameRecord :BloodBloomGameRecord = _games[index] as BloodBloomGameRecord;
            if( gameRecord.isFinished ) {
                _games.splice( index, 1);
                gameRecord.predators.forEach( function( predatorId :int) :void {
                    if( _playerId2Game.get(predatorId) == gameRecord) {
                        _playerId2Game.remove( predatorId );
                    }
                    
                });
                _playerId2Game.remove( gameRecord.prey );
            }
            else {
                index++;
            }
        }
    }
    
    
    
    protected function createNewBloodBloomGameRecord( predatorId :int, preyId :int ) :void
    {
        log.debug("createNewBloodBloomGameRecord ", "predatorId", predatorId, "preyId", preyId);
        var gameRecord :BloodBloomGameRecord = new BloodBloomGameRecord( _room, nextBloodBloomGameId, predatorId, preyId);
        _playerId2Game.put( predatorId, gameRecord );
        _playerId2Game.put( preyId, gameRecord );
        _games.push( gameRecord );
    }
    
    protected var _room :Room;
    protected var _playerId2Game :HashMap = new HashMap();
    protected var _games :Array = new Array();
    protected var _bloodBloomIdCounter :int = 0;
    
    protected static const log :Log = Log.getLog( BloomBloomStarter );
}
}