package redrover {

import com.threerings.flash.Vector2;

public class Constants
{
    public static const SCREEN_SIZE :Vector2 = new Vector2(700, 500);

    public static const BOARD_GRID_SIZE :int = 25;
    public static const BOARD_COLS :int = SCREEN_SIZE.x / BOARD_GRID_SIZE;
    public static const BOARD_ROWS :int = SCREEN_SIZE.y / BOARD_GRID_SIZE;

    public static const TEAM_RED :int = 0;
    public static const TEAM_BLUE :int = 1;
}

}
