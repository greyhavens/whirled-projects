package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.util.*;

public class Constants
{
    public static const DEBUG_SHOW_STATS :Boolean = true;

    public static const GAME_TIME :Number = 60 * 2;

    public static const PLAYER_PREDATOR :int = 0;
    public static const PLAYER_PREY :int = 1;

    public static const PREDATOR_SPEED_BASE :Number = 70;
    public static const PREDATOR_SPEED_DECREASE_PER_SECOND :Number = 4;
    public static const PREDATOR_SPEED_INCREASE_PER_DELIVERY :Number = 20;
    public static const PREDATOR_SPEED_MIN :Number = 20;
    public static const PREDATOR_SPEED_MAX :Number = 90;
    public static const MAX_PREDATOR_WHITE_CELLS :int = 3;

    public static const PREY_SPEED_BASE :Number = 70;
    public static const PREY_SPEED_DECREASE_PER_CELL :Number = 15;
    public static const PREY_SPEED_DECREASE_PER_SECOND :Number = 4;
    public static const PREY_SPEED_INCREASE_PER_DELIVERY :Number = 20;
    public static const PREY_SPEED_MIN :Number = 20;
    public static const PREY_SPEED_MAX :Number = 90;

    public static const CURSOR_RADIUS :Number = 9;
    public static const HEART_RADIUS :Number = 60;
    public static const HEART_RADIUS2 :Number = HEART_RADIUS * HEART_RADIUS;

    public static const BEAT_TIME_BASE :Number =                    16 / 4;
    public static const BEAT_TIME_MIN :Number =                     6 / 4;
    public static const BEAT_TIME_MAX :Number =                     16 / 4;
    public static const BEAT_TIME_INCREASE_PER_SECOND :Number =     0.05 / 4;
    public static const BEAT_TIME_DECREASE_PER_DELIVERY :Number =   1.5 / 4;

    public static const ARTERY_TOP :int = 0;
    public static const ARTERY_BOTTOM :int = 1;

    public static const CELL_RED :int = 0;
    public static const CELL_WHITE :int = 1;
    public static const CELL__LIMIT :int = 2;
    public static const INITIAL_CELL_COUNT :Array = [ 4, 2 ];
    public static const MAX_CELL_COUNT :Array = [ 60, 8 ];
    public static const RED_CELL_PROBABILITY :Number = 0.8;
    public static const BEAT_CELL_BIRTH_COUNT :NumRange = new NumRange(3, 3, Rand.STREAM_GAME);
    public static const CELL_BIRTH_DISTANCE :Array = [
        new NumRange(65, 90, Rand.STREAM_GAME),
        new NumRange(110, 140, Rand.STREAM_GAME)
    ];
    public static const CELL_BIRTH_TIME :Number = 0.5;
    public static const CELL_RADIUS :Number = 6;

    public static const BURST_RADIUS_MIN :Number = 9;
    public static const BURST_RADIUS_MAX :Number = 30;
    public static const BURST_EXPAND_TIME :Number = 1.5;
    public static const BURST_COMPLETE_TIME :Number = 3;
    public static const BURST_CONTRACT_TIME :Number = 1.5;

    public static const GAME_RADIUS :Number = 200;
    public static const GAME_CTR :Vector2 = new Vector2(267, 246);

    public static const GAME_RADIUS2 :Number = GAME_RADIUS * GAME_RADIUS;

    public static const HEMISPHERE_WEST :int = 0;
    public static const HEMISPHERE_EAST :int = 1;

    public static const PROP_RAND_SEED :String = "randSeed"; // uint
    public static const PROP_INITED :String = "inited"; // Boolean
}

}
