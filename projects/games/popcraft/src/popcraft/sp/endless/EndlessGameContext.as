package popcraft.sp.endless {

import popcraft.*;
import popcraft.data.EndlessLevelData;

public class EndlessGameContext
{
    public static var gameMode :EndlessGameMode;
    public static var level :EndlessLevelData;

    public static var playerMonitor :PlayerMonitor;

    public static var resourceScore :int;
    public static var damageScore :int;
    public static var resourceScoreThisRound :int;
    public static var damageScoreThisRound :int;
    public static var scoreMultiplier :Number;
    public static var mapIndex :int;
    public static var savedHumanPlayers :Array;
    public static var gameStarted :Boolean;
    public static var roundId :int;

    public static function get totalScore () :int
    {
        return resourceScore + damageScore;
    }

    public static function get totalScoreThisLevel () :int
    {
        return resourceScoreThisRound + damageScoreThisRound;
    }

    public static function get isNewGame () :Boolean
    {
        return !gameStarted;
    }

    public static function resetGameData () :void
    {
        EndlessGameContext.resetLevelData();

        resourceScore = 0;
        damageScore = 0;
        scoreMultiplier = 1;
        mapIndex = -1;
        savedHumanPlayers = [];

        if (playerMonitor != null) {
            playerMonitor.shutdown();
            playerMonitor = null;
        }

        if (GameContext.isMultiplayerGame) {
            playerMonitor = new PlayerMonitor(SeatingManager.numPlayers);
        }

        gameStarted = false;
        roundId = 0;
    }

    public static function resetLevelData () :void
    {
        resourceScoreThisRound = 0;
        damageScoreThisRound = 0;
    }

    public static function get mapCycleNumber () :int
    {
        // how many times has the player been through the map cycle?
        // (first time through, mapCycleNumber=0)

        return level.getMapCycleNumber(mapIndex);
    }

    public static function incrementResourceScore (offset :int) :void
    {
        offset *= scoreMultiplier;
        resourceScore += offset;
        resourceScoreThisRound += offset;
    }

    public static function incrementDamageScore (offset :int) :void
    {
        offset *= scoreMultiplier;
        damageScore += offset;
        damageScoreThisRound += offset;
    }

    public static function incrementMultiplier () :void
    {
        if (scoreMultiplier < level.maxMultiplier) {
            ++scoreMultiplier;
        } else {
            EndlessGameContext.incrementResourceScore(level.pointsPerExtraMultiplier);
        }
    }

    public static function decrementMultiplier () :void
    {
        scoreMultiplier = Math.max(scoreMultiplier - 1, 0);
    }
}

}
