package redrover {

import com.threerings.flash.Vector2;

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
    public static const TEAM_RED :int = 0;
    public static const TEAM_BLUE :int = 1;
    public static const NUM_TEAMS :int = 2;

    public static function getOtherTeam (teamId :int) :int
    {
        return (teamId == TEAM_RED ? TEAM_BLUE : TEAM_RED);
    }

    public static const TEAM_LEADER_NAMES :Array = [ "King", "Queen" ];

    public static const DIR_NORTH :int = 0;
    public static const DIR_WEST :int = 1;
    public static const DIR_SOUTH :int = 2;
    public static const DIR_EAST :int = 3;
    public static const DIRECTION_VECTORS :Array = [
        new Vector2(0, -1), new Vector2(-1, 0), new Vector2(0, 1), new Vector2(1, 0)
    ];

    public static function getDirection (xOffset :int, yOffset :int) :int
    {
        if (xOffset > 0) {
            return DIR_EAST;
        } else if (xOffset < 0) {
            return DIR_WEST;
        } else if (yOffset > 0) {
            return DIR_SOUTH;
        } else if (yOffset < 0) {
            return DIR_NORTH;
        }

        return -1;
    }

    public static function isParallel (dirA :int, dirB :int) :Boolean
    {
        var d :int = Math.abs(dirB - dirA);
        return (d == 0 || d == 2);
    }

    public static function isPerp (dirA :int, dirB :int) :Boolean
    {
        return !isParallel(dirA, dirB);
    }

    public static function isHoriz (direction :int) :Boolean
    {
        return (direction == DIR_EAST || direction == DIR_WEST);
    }

    public static function isVert (direction :int) :Boolean
    {
        return (direction == DIR_NORTH || direction == DIR_SOUTH);
    }

    public static const GEM_GREEN :int = 0;
    public static const GEM_PURPLE :int = 1;
    public static const GEM__LIMIT :int = 2;

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
