package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.util.*;

public class Constants
{
    public static const PLAYER_PREDATOR :int = 0;
    public static const PLAYER_PREY :int = 1;

    public static const PREY_SPEED_BASE :Number = 65;
    public static const PREY_SPEED_CELL_OFFSET :Number = -10;
    public static const PREY_SPEED_MIN :Number = 15;

    public static const CURSOR_RADIUS :Number = 9;

    public static const BEAT_TIME :Number = 1;

    public static const ARTERY_TOP :int = 0;
    public static const ARTERY_BOTTOM :int = 1;

    public static const CELL_RED :int = 0;
    public static const CELL_WHITE :int = 1;
    public static const CELL__LIMIT :int = 2;
    public static const INITIAL_CELL_COUNT :Array = [ 30, 10 ];
    public static const MAX_CELL_COUNT :Array = [ 50, 50 ];
    public static const CELL_SPAWN_RATE :Array = [
        new NumRange(5, 7, Rand.STREAM_GAME), new NumRange(6, 8, Rand.STREAM_GAME)
    ];
    public static const CELL_SPAWN_RADIUS :NumRange = new NumRange(50, 170, Rand.STREAM_GAME);
    public static const CELL_RADIUS :Number = 9;
    public static const GAME_RADIUS :Number = 200;
    public static const GAME_CTR :Vector2 = new Vector2(267, 246);

    public static const GAME_RADIUS2 :Number = GAME_RADIUS * GAME_RADIUS;
}

}
