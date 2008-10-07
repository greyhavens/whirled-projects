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

    public static function reset () :void
    {
        score = 0;
        scoreMultiplier = 1;
        mapDataIndex = -1;
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
