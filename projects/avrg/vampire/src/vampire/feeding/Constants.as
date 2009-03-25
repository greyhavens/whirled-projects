package vampire.feeding {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.util.*;

public class Constants
{
    public static const DEBUG_SHOW_STATS :Boolean = false;
    public static const DEBUG_DISABLE_AUDIO :Boolean = false;
    public static const DEBUG_FORCE_SPECIAL_BLOOD_STRAIN :Boolean = false;

    public static const GAME_TIME :Number = 60 * 2;

    public static const PLAYER_PREDATOR :int = 0;
    public static const PLAYER_PREY :int = 1;

    public static const CURSOR_SPEED :Number = 70;
    public static const CURSOR_RADIUS :Number = 9;

    public static const HEART_RADIUS :Number = 55;
    public static const HEART_RADIUS2 :Number = HEART_RADIUS * HEART_RADIUS;

    public static const CREATE_BONUS_BURST_SIZE :int = 3;

    public static const BEAT_TIME :Number = 4;

    public static const ARTERY_TOP :int = 0;
    public static const ARTERY_BOTTOM :int = 1;

    public static const CELL_RED :int = 0;
    public static const CELL_WHITE :int = 1;
    public static const CELL_MULTIPLIER :int = 2;
    public static const CELL_SPECIAL :int = 3;
    public static const MAX_CELL_COUNT :Array = [ 60, 8, 999, 1 ];
    public static const BEAT_CELL_BIRTH_COUNT :IntRange = new IntRange(3, 4, Rand.STREAM_GAME);
    public static const CELL_BIRTH_DISTANCE :Array = [
        new NumRange(65, 85, Rand.STREAM_GAME),     // Red
        new NumRange(190, 195, Rand.STREAM_GAME),   // White
        new NumRange(145, 150, Rand.STREAM_GAME),   // Multiplier
        new NumRange(160, 170, Rand.STREAM_GAME),   // Special
    ];
    public static const CELL_RADIUS :Array = [ 8, 8, 8, 21 ];
    public static const CELL_BIRTH_TIME :Number = 0.5;

    public static const BURST_RED :int = 0;
    public static const BURST_WHITE :int = 1;
    public static const BURST_MULTIPLIER :int = 2;
    public static const BURST_BLACK :int = 3;
    public static const BURST_SPECIAL :int = 4;

    public static const WHITE_CELL_CREATION_TIME :NumRange = new NumRange(7, 9, Rand.STREAM_GAME);
    public static const WHITE_CELL_CREATION_COUNT :IntRange = new IntRange(1, 3, Rand.STREAM_GAME);
    public static const WHITE_CELL_NORMAL_TIME :NumRange = new NumRange(8, 8, Rand.STREAM_GAME);
    public static const WHITE_CELL_EXPLODE_TIME :Number = 7;

    public static const SPECIAL_CELL_CREATION_TIME :NumRange =
        new NumRange(30, 90, Rand.STREAM_GAME);
    public static const MAX_COLLECTIONS_PER_STRAIN :int = 3;

    public static const RED_BURST_RADIUS_MIN :Number = 8;
    public static const RED_BURST_RADIUS_MAX :Number = 40;
    public static const WHITE_BURST_RADIUS_MIN :Number = 13;
    public static const WHITE_BURST_RADIUS_MAX :Number = 50;
    public static const BLACK_BURST_RADIUS_MIN :Number = 8;
    public static const BLACK_BURST_RADIUS_MAX :Number = 40;
    public static const BURST_EXPAND_TIME :Number = 1.5;
    public static const BURST_COMPLETE_TIME :Number = 2;
    public static const BURST_CONTRACT_TIME :Number = 1.5;

    public static const GAME_RADIUS :Number = 200;
    public static const GAME_RADIUS2 :Number = GAME_RADIUS * GAME_RADIUS;
    public static const GAME_CTR :Vector2 = new Vector2(267, 246);

    public static const HEMISPHERE_WEST :int = 0;
    public static const HEMISPHERE_EAST :int = 1;

    public static const SP_MULTIPLIER_RETURN_CHANCE :Number = 1;
    public static const SP_MULTIPLIER_RETURN_TIME :NumRange = new NumRange(4, 9, Rand.STREAM_GAME);

    public static const MAX_MULTIPLIER :int = 100;

    public static const DEBRIS_COUNT :int = 12;

    public static const NULL_PLAYER :int = 0;

    public static const MODE_LOBBY :String = "m_Lobby";
    public static const MODE_PLAYING :String = "m_Playing";
}

}
