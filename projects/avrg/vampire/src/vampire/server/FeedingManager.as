package vampire.server
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.SimObject;

public class FeedingManager extends SimObject
{
    public function FeedingManager(room :Room)
    {
        _room = room;
    }

    override protected function destroyed () :void
    {
        var gamesShutdown :HashSet = new HashSet();

        for each (var game :FeedingRecord in _games) {
            game.shutdown();
        }

        _games.splice(0);
        _room = null;
    }

    protected function get nextBloodBloomGameId() :int
    {
        return ++_bloodBloomIdCounter;
    }

    public function requestFeed(predatorId :int, preyId :int, preyName :String,
        preyLocation :Array) :FeedingRecord
    {
        log.debug("begin requestFeed ", "predatorId", predatorId, "preyId", preyId,
            "preyName", preyName, "this", this);

//        var currentGame :FeedingRecord = _playerId2Game.get(predatorId) as FeedingRecord;

        var currentPredGame :FeedingRecord = getGame(predatorId);
        if(currentPredGame != null) {
            log.debug(predatorId + " doing nothing, I am already in a game. Game=" + currentPredGame);
            return currentPredGame;
//            if(currentGame.preyId == preyId) {
//                log.debug(predatorId + " doing nothing, prey is already in a game I am also in. Game=" + currentGame);
//            }
//            else {
//                log.debug(predatorId + "  I am alrady in a game with a different prey.  Staying in the current game=" + currentGame);
////                currentGame.playerLeavesGame(predatorId);
////                _playerId2Game.remove(predatorId);
////                log.debug(predatorId + "  I am alrady in a game with a different prey, so leaving that game. Game=" + currentGame);
////                return null;
//            }
        }

        var currentPreyGame :FeedingRecord = getGame(preyId);

        if (currentPreyGame != null) {
            log.debug(predatorId + " requestFeed, prey is already in game, joining lobby", "currentPreyGame", currentPreyGame);
            currentPreyGame.joinLobby(predatorId);
            log.debug(predatorId + " requestFeed, after joining lobby", "currentPreyGame", currentPreyGame);
            return currentPreyGame;
        }
        else {
            log.debug(predatorId + " requestFeed, creating a new game");
            return createNewBloodBloomGameRecord(predatorId, preyId, preyName, preyLocation);
        }


//        if(_playerId2Game.containsKey(preyId)) {
//            log.debug(predatorId + " requestFeed, adding to existing game");
//            var gameRecord :FeedingRecord = _playerId2Game.get(preyId) as FeedingRecord;
//            gameRecord.addPredator(predatorId, preyLocation);
//            _playerId2Game.put(predatorId, gameRecord);
////            if(!gameRecord.isStarted) {
////            }
////            else {
////                _room.addFeedback("You cannot join a game already in progress.", predatorId);
////            }
//            return gameRecord;
//        }
//        else {
//            log.debug(predatorId + " requestFeed, creating a new game");
//            return createNewBloodBloomGameRecord(predatorId, preyId, preyName, preyLocation);
//        }
    }

    public function getGame (playerId :int) :FeedingRecord
    {
//        log.info(
        for each (var record :FeedingRecord in _games) {
            if (ArrayUtil.contains(record.gameServer.playerIds, playerId)) {
                return record;
            }
        }
        return null;
    }

//    protected function gameFinishedCallback (record :FeedingRecord) :void
//    {
//        for each(var playerId :int in record.playerIds) {
//            _playerId2Game.remove(playerId);
//        }
//    }

//    protected function playerLeavesCallback (playerId :int) :void
//    {
//        _playerId2Game.remove(playerId);
//    }

    override protected function update (dt :Number) :void
    {

//        for each(var game :BloodBloomGameRecord in _games) {
//            game.update(dt);
//        }
        removeFinishedGames();
    }

    protected function removeFinishedGames () :void
    {
        var index :int = 0;
        while (index < _games.length) {
            var gameRecord :FeedingRecord = _games[index] as FeedingRecord;
            if (gameRecord == null ||
                gameRecord.gameServer == null ||
                gameRecord.gameServer.playerIds.length == 0) {

                _games.splice(index, 1);

//                log.debug("Removing finished BloodBloomGameRecord");
//                gameRecord.predators.forEach(function(predatorId :int) :void {
//                    if(_playerId2Game.get(predatorId) == gameRecord) {
//                        _playerId2Game.remove(predatorId);
//                    }
//                });

                //Set the avatars to the default state after a game.
//                for each(var playerId :int in gameRecord.playerIds) {
//                    if(_room.isPlayer(playerId)) {
//                        ServerLogic.stateChange(_room.getPlayer(playerId), VConstants.PLAYER_STATE_DEFAULT);
//                    }
//                }

//                _playerId2Game.remove(gameRecord.preyId);
//                gameRecord.shutdown();
            }
            else {
                index++;
            }
        }
    }

    public function playerQuitsGameOrRoom (playerId :int) :void
    {
        for each (var record :FeedingRecord in _games) {
            record.playerLeavesGame(playerId);
        }
//        var record :FeedingRecord = getGame(playerId);
//        if (record != null) {
//            record.playerLeavesGame(playerId);
//        }
//        else {
//            log.debug("playerQuitsGame, player not a mamber of any game", "playerId", playerId);
//        }


//        if(_playerId2Game.containsKey(playerId)) {
//            var gameRecord :FeedingRecord = _playerId2Game.get(playerId) as FeedingRecord;
//            gameRecord.playerLeavesGame(playerId, true);
////            gameRecord.removePlayer(playerId);
//            _playerId2Game.remove(playerId);
//        }
    }

//    public function isPredatorInGame (playerId :int) :Boolean
//    {
//        if(!_playerId2Game.containsKey(playerId)) {
////            log.debug("isPredatorInGame(" + playerId + "), but no key in _playerId2Game, _playerId2Game.keys=" + _playerId2Game.keys());
//            return false;
//        }
//
//        var game :FeedingRecord = _playerId2Game.get(playerId) as FeedingRecord;
//
//        var isPredator :Boolean = game.isPredator(playerId);
//        log.debug("isPredatorInGame(" + playerId + ") returning " + isPredator);
//        return isPredator;
//    }

    public function isPreyInGame (playerId :int) :Boolean
    {
        var record :FeedingRecord = getGame(playerId);
        if (record != null) {
            return record.gameServer.preyId == playerId;
        }
        return false;

//        if(!_playerId2Game.containsKey(playerId)) {
//            return false;
//        }
//
//        var game :FeedingRecord = _playerId2Game.get(playerId) as FeedingRecord;
//        return game.isPrey(playerId);
    }

//    public function getGame(playerId :int) :FeedingRecord
//    {
//        if(!_playerId2Game.containsKey(playerId)) {
//            log.debug("getGame(" + playerId + "), but us=" + toString());
//            return null;
//        }
//
//        return _playerId2Game.get(playerId) as FeedingRecord;
//    }


    protected function createNewBloodBloomGameRecord(predatorId :int, preyId :int,
        preyName :String, preyLocation :Array) :FeedingRecord
    {
        log.debug("createNewBloodBloomGameRecord ", "predatorId", predatorId, "preyId", preyId,
            "preyName", preyName);
        var gameRecord :FeedingRecord = new FeedingRecord(_room,
            nextBloodBloomGameId, predatorId, preyId, preyName, preyLocation);//,
//            gameFinishedCallback, playerLeavesCallback);
//        _playerId2Game.put(predatorId, gameRecord);
//        if(preyId > 0) {
//            _playerId2Game.put(preyId, gameRecord);
//        }
        _games.push(gameRecord);

        return gameRecord;
    }

//    public function get players() :Array
//    {
//
//
//        var keys :Array = _playerId2Game.keys();
//        keys.sort();
//        return keys;
//    }

    public function get unavailablePlayers() :Array
    {
         var playerids :Array = new Array();
         for each (var record :FeedingRecord in _games) {
             for each (var predId :int in record.gameServer.predatorIds) {
                 playerids.push(predId);
             }
         }


//
//         _playerId2Game.forEach(function(playerId :int, game :FeedingRecord) :void {
//
//             if (game.isPredator(playerId)){
//                 playerids.push(playerId);
//             }
////             else if (game.isStarted){
////                 playerids.push(playerId);
////             }
//         });
         return playerids;
    }

    public function get primaryPreds() :Array
    {
         var playerids :Array = new Array();
         for each (var record :FeedingRecord in _games) {
             playerids.push(record.gameServer.primaryPredatorId);
         }
         return playerids;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this)
            + "\n games.length=" + _games.length
//            + "\n playerId2Game.size()=" + _playerId2Game.size()
//            + "\n playerId2Game.keys()=" + _playerId2Game.keys()
            + "\n games listed:\n  " + _games.join("\n  ")
    }

    protected var _room :Room;
//    protected var _playerId2Game :HashMap = new HashMap();
    protected var _games :Array = new Array();
    protected var _bloodBloomIdCounter :int = 0;

    protected static const log :Log = Log.getLog(FeedingManager);
}
}