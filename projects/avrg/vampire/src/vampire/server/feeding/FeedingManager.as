package vampire.server.feeding
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.SimObject;

import vampire.server.Room;

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
            "preyName", preyName, "preyLocation", preyLocation, "this", this);

        var currentPredGame :FeedingRecord = getGame(predatorId);
        if(currentPredGame != null) {
            log.debug(predatorId + " doing nothing, I am already in a game. Game=" + currentPredGame);
            return currentPredGame;
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
    }

    public function getGame (playerId :int) :FeedingRecord
    {
        if (playerId == 0) {
            return null;
        }
        for each (var record :FeedingRecord in _games) {

            if (record.gameServer.playerIds.length == 0) {
                continue;
            }

            if (record.preyId == playerId) {
                return record;
            }
            if (ArrayUtil.contains(record.gameServer.playerIds, playerId)) {
                return record;
            }
        }
        return null;
    }

    override protected function update (dt :Number) :void
    {
        removeFinishedGames();
    }

    public function removeFinishedGames () :void
    {
        var index :int = 0;
        while (index < _games.length) {
            var gameRecord :FeedingRecord = _games[index] as FeedingRecord;
            if (gameRecord == null ||
                gameRecord.gameServer == null ||
                gameRecord.gameServer.playerIds == null ||
                gameRecord.gameServer.playerIds.length == 0) {

                _games.splice(index, 1);
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
    }

    public function isPreyInGame (playerId :int) :Boolean
    {
        var record :FeedingRecord = getGame(playerId);
        if (record != null) {
            return record.gameServer.preyId == playerId;
        }
        return false;
    }

    protected function createNewBloodBloomGameRecord(predatorId :int, preyId :int,
        preyName :String, preyLocation :Array) :FeedingRecord
    {
        log.debug("createNewBloodBloomGameRecord", "predatorId", predatorId, "preyId", preyId,
            "preyName", preyName, "preyLocation", preyLocation);
        var gameRecord :FeedingRecord = new FeedingRecord(_room,
            nextBloodBloomGameId, predatorId, preyId, preyName, preyLocation, removeFinishedGames);
        _games.push(gameRecord);

        return gameRecord;
    }

    public function get unavailablePlayers() :Array
    {
         var playerids :Array = new Array();
         for each (var record :FeedingRecord in _games) {
             for each (var predId :int in record.gameServer.predatorIds) {
                 playerids.push(predId);
             }
         }
         return playerids;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this)
            + "\n games.length=" + _games.length
            + "\n games listed:\n  " + _games.join("\n  ")
    }

    protected var _room :Room;
    protected var _games :Array = new Array();
    protected var _bloodBloomIdCounter :int = 0;

    protected static const log :Log = Log.getLog(FeedingManager);
}
}