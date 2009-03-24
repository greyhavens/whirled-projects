package vampire.server
{
    import com.threerings.util.ClassUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.SimObject;

    import vampire.data.VConstants;

public class FeedingManager extends SimObject
{
    public function FeedingManager( room :Room )
    {
        _room = room;

    }

    override protected function destroyed () :void
    {
        var gamesShutdown :HashSet = new HashSet();
        _playerId2Game.forEach( function( playerId :int, game :FeedingRecord) :void {
            if( game.isFinished ) {
                gamesShutdown.add( game.gameServer.gameId );
            }
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
        var gameRecord :FeedingRecord = _playerId2Game.get( predatorId ) as FeedingRecord;
        if( gameRecord != null) {
            log.debug("predatorBeginsGame ", "predatorId", predatorId);
            gameRecord.startLobby();
        }
        else {
            log.debug("predatorBeginsGame, but no game for that record", "predatorId", predatorId);
        }
    }

    protected function get nextBloodBloomGameId() :int
    {
        return ++_bloodBloomIdCounter;
    }

    public function requestFeed( predatorId :int, preyId :int, preyName :String,
        preyLocation :Array ) :FeedingRecord
    {
        log.debug("begin requestFeed ", "predatorId", predatorId, "preyId", preyId,
            "preyName", preyName);
//            "BloodBloomManager", this);

        var currentGame :FeedingRecord = _playerId2Game.get( predatorId ) as FeedingRecord;
        if( currentGame != null ) {
            if( currentGame.preyId == preyId ) {
                log.debug(predatorId + " doing nothing, prey is already in a game I am also in. Game=" + currentGame);
            }
            else {
                currentGame.playerLeavesGame(predatorId);
                _playerId2Game.remove( predatorId );
                log.debug(predatorId + "  I am alrady in a game with a different prey, so leaving that game. Game=" + currentGame);
            }
        }


        if( _playerId2Game.containsKey( preyId ) ) {
            log.debug(predatorId + " requestFeed, adding to existing game");
            var gameRecord :FeedingRecord = _playerId2Game.get( preyId ) as FeedingRecord;
            gameRecord.addPredator( predatorId, preyLocation );
            _playerId2Game.put( predatorId, gameRecord );
//            if( !gameRecord.isStarted ) {
//            }
//            else {
//                _room.addFeedback("You cannot join a game already in progress.", predatorId);
//            }
            return gameRecord;
        }
        else {
            log.debug(predatorId + " requestFeed, creating a new game");
            return createNewBloodBloomGameRecord( predatorId, preyId, preyName, preyLocation );
        }
    }

    protected function gameFinishedCallback (record :FeedingRecord) :void
    {
        for each( var playerId :int in record.playerIds ) {
            _playerId2Game.remove(playerId);
        }
    }

    protected function playerLeavesCallback (playerId :int) :void
    {
        _playerId2Game.remove(playerId);
    }

    override protected function update (dt :Number) :void
    {

//        for each( var game :BloodBloomGameRecord in _games ) {
//            game.update( dt );
//        }
        removeFinishedGames();
    }

    protected function removeFinishedGames () :void
    {
        var index :int = 0;
        while( index < _games.length) {
            var gameRecord :FeedingRecord = _games[index] as FeedingRecord;
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
                        ServerLogic.stateChange( _room.getPlayer( playerId ), VConstants.PLAYER_STATE_DEFAULT);
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

    public function playerQuitsGame (playerId :int) :void
    {
        if( _playerId2Game.containsKey( playerId ) ) {
            var gameRecord :FeedingRecord = _playerId2Game.get( playerId ) as FeedingRecord;
            gameRecord.playerLeavesGame(playerId, true);
//            gameRecord.removePlayer( playerId );
            _playerId2Game.remove( playerId );
        }
    }

    public function isPredatorInGame (playerId :int) :Boolean
    {
        if( !_playerId2Game.containsKey( playerId )) {
//            log.debug("isPredatorInGame(" + playerId + "), but no key in _playerId2Game, _playerId2Game.keys=" + _playerId2Game.keys());
            return false;
        }

        var game :FeedingRecord = _playerId2Game.get( playerId ) as FeedingRecord;

        var isPredator :Boolean = game.isPredator( playerId );
        log.debug("isPredatorInGame(" + playerId + ") returning " + isPredator);
        return isPredator;
    }

    public function isPreyInGame (playerId :int) :Boolean
    {
        if( !_playerId2Game.containsKey( playerId )) {
            return false;
        }

        var game :FeedingRecord = _playerId2Game.get( playerId ) as FeedingRecord;
        return game.isPrey( playerId );
    }

    public function getGame( playerId :int ) :FeedingRecord
    {
        if( !_playerId2Game.containsKey( playerId )) {
            log.debug("getGame(" + playerId + "), but us=" + toString());
            return null;
        }

        return _playerId2Game.get( playerId ) as FeedingRecord;
    }


    protected function createNewBloodBloomGameRecord( predatorId :int, preyId :int,
        preyName :String, preyLocation :Array ) :FeedingRecord
    {
        log.debug("createNewBloodBloomGameRecord ", "predatorId", predatorId, "preyId", preyId,
            "preyName", preyName);
        var gameRecord :FeedingRecord = new FeedingRecord( _room,
            nextBloodBloomGameId, predatorId, preyId, preyName, preyLocation,
            gameFinishedCallback, playerLeavesCallback);
        _playerId2Game.put( predatorId, gameRecord );
        if( preyId > 0 ) {
            _playerId2Game.put( preyId, gameRecord );
        }
        _games.push( gameRecord );

        return gameRecord;
    }

    public function get players() :Array
    {
        var keys :Array = _playerId2Game.keys();
        keys.sort();
        return keys;
    }

    public function get unavailablePlayers() :Array
    {
         var playerids :Array = new Array();
         _playerId2Game.forEach( function(playerId :int, game :FeedingRecord) :void {

             if (game.isPredator(playerId)){
                 playerids.push(playerId);
             }
//             else if (game.isStarted){
//                 playerids.push(playerId);
//             }
         });
         return playerids;
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

    protected static const log :Log = Log.getLog( FeedingManager );
}
}