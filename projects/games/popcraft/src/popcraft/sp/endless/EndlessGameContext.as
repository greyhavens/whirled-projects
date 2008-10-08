package popcraft.sp.endless {

import popcraft.data.EndlessLevelData;
import popcraft.data.EndlessMapData;

public class EndlessGameContext
{
    public static var gameMode :EndlessGameMode;
    public static var level :EndlessLevelData;

    public static var score :int;
    public static var scoreMultiplier :Number;
    public static var mapDataIndex :int;
    public static var savedLocalPlayer :SavedPlayerInfo;
    public static var savedRemotePlayer :SavedPlayerInfo;

    public static function reset () :void
    {
        score = 0;
        scoreMultiplier = 1;
        mapDataIndex = -1;
        savedLocalPlayer = null;
        savedRemotePlayer = null;
    }

    public static function cycleMapData () :EndlessMapData
    {
        var mapData :EndlessMapData =
            level.mapSequence[(++mapDataIndex) % level.mapSequence.length];
        if (mapDataIndex >= level.mapSequence.length && !mapData.repeats) {
            cycleMapData();
        }

        return mapData;
    }

    public static function get mapCycleNumber () :int
    {
        // how many times has the player been through the map cycle?
        // (first time through, mapCycleNumber=0)

        var firstCycleLength :int = level.mapSequence.length;
        var repeatCycleLength :int;
        for each (var mapData :EndlessMapData in level.mapSequence) {
            if (mapData.repeats) {
                ++repeatCycleLength;
            }
        }

        return (mapDataIndex < firstCycleLength ? 0 :
                Math.ceil((mapDataIndex + 1 - firstCycleLength) / repeatCycleLength));
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
