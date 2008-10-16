package popcraft.sp.endless {

import popcraft.*;
import popcraft.data.EndlessLevelData;
import popcraft.data.EndlessMapData;

public class EndlessGameContext
{
    public static var gameMode :EndlessGameMode;
    public static var level :EndlessLevelData;

    public static var playerReadyMonitor :PlayerReadyMonitor;

    public static var score :int;
    public static var scoreMultiplier :Number;
    public static var mapIndex :int;
    public static var savedHumanPlayers :Array;
    public static var numMultiplierObjects :int;

    public static function get isNewGame () :Boolean
    {
        // used by EndlessGameMode.setup to determine if this is a new game, or simply
        // the next map in an existing game
        return (mapIndex <= 0);
    }

    public static function reset () :void
    {
        score = 0;
        scoreMultiplier = 1;
        mapIndex = -1;
        savedHumanPlayers = [];
        numMultiplierObjects = 0;

        if (playerReadyMonitor != null) {
            playerReadyMonitor.shutdown();
            playerReadyMonitor = null;
        }

        if (GameContext.isMultiplayerGame) {
            playerReadyMonitor = new PlayerReadyMonitor(SeatingManager.numPlayers);
        }
    }

    public static function get mapCycleNumber () :int
    {
        // how many times has the player been through the map cycle?
        // (first time through, mapCycleNumber=0)

        return level.getMapCycleNumber(mapIndex);
    }

    public static function incrementScore (offset :int) :void
    {
        score += (offset * scoreMultiplier);
    }

    public static function incrementMultiplier () :void
    {
        if (scoreMultiplier < level.maxMultiplier) {
            ++scoreMultiplier;
        } else {
            incrementScore(level.pointsPerExtraMultiplier);
        }
    }

    public static function decrementMultiplier () :void
    {
        scoreMultiplier = Math.max(scoreMultiplier - 1, 0);
    }
}

}
