package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.util.*;

public class Constants
{
    public static const PLAYER_PREDATOR :int = 0;
    public static const PLAYER_PREY :int = 1;

    public static const PREDATOR_BLOOD_TARGET :int = 1000;

    public static const PREDATOR_SPEED_BASE :Number = 65;
    public static const MAX_PREDATOR_WHITE_CELLS :int = 3;

    public static const PREY_SPEED_BASE :Number = 65;
    public static const PREY_SPEED_CELL_OFFSET :Number = -10;
    public static const PREY_SPEED_MIN :Number = 15;

    public static const CURSOR_RADIUS :Number = 9;
    public static const HEART_RADIUS :Number = 60;
    public static const HEART_RADIUS2 :Number = HEART_RADIUS * HEART_RADIUS;

    public static const BEAT_TIME_BASE :Number = 8 / 4;
    public static const BEAT_TIME_MIN :Number = 1 / 4;
    public static const BEAT_SPEED_UP :Number = 0.1 / 4;
    public static const BEAT_ARTERY_SLOW_DOWN :Number = 0.6 / 4;

    public static const ARTERY_TOP :int = 0;
    public static const ARTERY_BOTTOM :int = 1;

    public static const CELL_RED :int = 0;
    public static const CELL_WHITE :int = 1;
    public static const CELL__LIMIT :int = 2;
    public static const MAX_CELL_COUNT :Number = 100;
    public static const RED_CELL_PROBABILITY :Number = 0.8;
    public static const BEAT_CELL_BIRTH_COUNT :NumRange = new NumRange(3, 6, Rand.STREAM_GAME);
    public static const CELL_BIRTH_DISTANCE :Array = [
        new NumRange(65, 100, Rand.STREAM_GAME),
        new NumRange(90, 140, Rand.STREAM_GAME)
    ];
    public static const CELL_BIRTH_TIME :Number = 0.5;
    public static const CELL_RADIUS :Number = 9;

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

    public static const HEARTBEAT_TIME :Number = 1/30;
    public static const MSG_S_HEARTBEAT :String = "sTick";
    public static const MSG_C_CHOOSE_PLAYER :String = "cChoosePlayer"; // int - player type

    public static const PROP_RAND_SEED :String = "randSeed"; // uint
    public static const PROP_INITED :String = "inited"; // Boolean
}

}
