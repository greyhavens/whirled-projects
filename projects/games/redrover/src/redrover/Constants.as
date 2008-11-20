package redrover {

import com.threerings.flash.Vector2;

import redrover.util.IntValueTable;

public class Constants
{
    /* Debug options */
    public static const DEBUG_LOAD_LEVELS_FROM_DISK :Boolean = true;
    public static const DEBUG_ALLOW_CHEATS :Boolean = true;
    public static const DEBUG_DISABLE_AUDIO :Boolean = true;

    public static const SCREEN_SIZE :Vector2 = new Vector2(700, 500);
    public static const SOUND_MASTER_VOLUME :Number = 1.0;

    /* ResourceManager stuff */
    public static const RESTYPE_LEVEL :String = "level";

    /* Game settings */
    public static const GEM_SPAWN_MIN :Number = 3;
    public static const GEM_SPAWN_MAX :Number = 3;

    public static const BASE_MOVE_SPEED :Number = 80;
    public static const MOVE_SPEED_GEM_OFFSET :Number = -5;
    public static const MAX_PLAYER_GEMS :int = 10;

    public static const GEM_VALUE :IntValueTable = new IntValueTable([0, 10, 20, 30, 50, 80], 40);

    public static const SWITCH_BOARDS_TIME :Number = 1;
    public static const RETURN_HOME_GEMS_MIN :int = 3;

    public static const TEAM_RED :int = 0;
    public static const TEAM_BLUE :int = 1;
    public static const NUM_TEAMS :int = 2;

    public static function getOtherTeam (teamId :int) :int
    {
        return (teamId == TEAM_RED ? TEAM_BLUE : TEAM_RED);
    }

    public static const PLAYER_COLORS :Array = [
        0xFFFFFF,
        0x9FBCFF,
        0xFF0000,
        0x9C78E4,
        0x47880A,
        0x996633,
        0xFF8000,
        0x0000BB,
        0xFF6FCF,
        0x333333,
    ];

    public static const OWN_BOARD_ZOOM :Number = 1.5;
    public static const OTHER_BOARD_ZOOM :Number = 1;

    public static const DIR_NORTH :int = 0;
    public static const DIR_WEST :int = 1;
    public static const DIR_SOUTH :int = 2;
    public static const DIR_EAST :int = 3;

    public static const GEM_GREEN :int = 0;
    public static const GEM_PURPLE :int = 1;
    public static const GEM__LIMIT :int = 2;

    public static const SLOW_TERRAIN_SPEED :Number = 0.5;

    public static const TERRAIN_NORMAL :int = 0;
    public static const TERRAIN_OBSTACLE :int = 1;
    public static const TERRAIN_SLOW :int = 2;
    public static const TERRAIN_GEMREDEMPTION :int = 3;
    public static const TERRAIN_SYMBOLS :Array = [ ".", "#", "*", "!" ];

    public static const OBJ_GREENSPAWNER :int = 0;
    public static const OBJ_PURPLESPAWNER :int = 1;
    public static const OBJ_SYMBOLS :Array = [ "G", "P" ];
}

}
