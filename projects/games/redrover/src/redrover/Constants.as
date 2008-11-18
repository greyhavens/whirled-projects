package redrover {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.util.NumRange;
import com.whirled.contrib.simplegame.util.Rand;

import redrover.util.IntValueTable;

public class Constants
{
    public static const SCREEN_SIZE :Vector2 = new Vector2(700, 500);

    public static const NUM_TEAMS :int = 2;

    public static const BOARD_CELL_SIZE :int = 50;
    public static const BOARD_COLS :int = SCREEN_SIZE.x / BOARD_CELL_SIZE;
    public static const BOARD_ROWS :int = SCREEN_SIZE.y / BOARD_CELL_SIZE;

    public static const MAX_BOARD_GEMS :int = 16;
    public static const GEM_SPAWN_TIME :NumRange = new NumRange(1, 1, Rand.STREAM_GAME);

    public static const BASE_MOVE_SPEED :Number = 50;
    public static const MOVE_SPEED_GEM_OFFSET :Number = -5;

    public static const GEM_VALUE :IntValueTable = new IntValueTable([1, 2, 3, 4], 5);

    public static const RETURN_HOME_COST :int = 4;

    public static const TEAM_RED :int = 0;
    public static const TEAM_BLUE :int = 1;
}

}
