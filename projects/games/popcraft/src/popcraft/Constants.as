package popcraft {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;

import flash.geom.Point;

import popcraft.battle.*;
import popcraft.data.*;
import popcraft.util.*;

public class Constants
{
    public static const SCREEN_DIMS :Vector2 = new Vector2(700, 500);

    /* Debug options */
    public static const DEBUG_DRAW_STATS :Boolean = true;
    public static const DEBUG_CHECKSUM_STATE :int = 0;
    public static const DEBUG_ALLOW_CHEATS :Boolean = true;
    public static const DEBUG_DRAW_UNIT_DATA_CIRCLES :Boolean = false;
    public static const DEBUG_DRAW_AOE_ATTACK_RADIUS :Boolean = false;
    public static const DEBUG_DISABLE_MOVEMENT_SMOOTHING :Boolean = false;
    public static const DEBUG_DISABLE_DIURNAL_CYCLE :Boolean = false;
    public static const DEBUG_LOAD_LEVELS_FROM_DISK :Boolean = true;

    /* Screen layout */
    public static const BATTLE_BOARD_LOC :Point = new Point(0, 0);

    public static const RESOURCE_DISPLAY_LOC :Point = new Point(350, 380);
    public static const PUZZLE_BOARD_LOC :Point = new Point(10, 378);
    public static const RESOURCE_POPUP_LOC :Point = new Point(275, 425);
    public static const DIURNAL_METER_LOC :Point = new Point(255, 2);
    public static const UNIT_QUEUE_LOC :Point = new Point(530, 400);

    public static const FIRST_UNIT_BUTTON_LOC :Point = new Point(350, 400);

    public static const PLAYER_COLORS :Array = [
       uint(0xFFFF0000),
       uint(0xFF9FBCFF),
       uint(0xFF51FF7E),
       uint(0xFFFFE75F)
    ];

    /* Puzzle stuff */
    public static const MIN_GROUP_SIZE :int = 1; // no min group size right now

    public static const PUZZLE_HEIGHT :int = 110;

    public static const PUZZLE_COLS :int = 12;
    public static const PUZZLE_ROWS :int = 5;

    public static const PUZZLE_TILE_SIZE :int = int(PUZZLE_HEIGHT / PUZZLE_ROWS);

    // @TODO - move this into GameData
    public static const CLEAR_VALUE_TABLE :IntValueTable =
        new IntValueTable( [-20, -10, 10, 10 ] );
             // group size:   1,   2,  3,  4+ = 20, 30, 40, ...

    /* Battle stuff */
    public static const BATTLE_WIDTH :int = 700;
    public static const BATTLE_HEIGHT :int = 372;

    public static const PHASE_DAY :uint = 0;
    public static const PHASE_NIGHT :uint = 1;

    public static const DAY_PHASE_NAMES :Array = [ "day", "night" ];

    /* Damage types */
    public static const DAMAGE_TYPE_CRUSHING :uint = 0;
    public static const DAMAGE_TYPE_PIERCING :uint = 1;
    public static const DAMAGE_TYPE_EXPLOSION :uint = 2;
    public static const DAMAGE_TYPE_BASE :uint = 3; // bases damage units that attack them

    public static const DAMAGE_TYPE_NAMES :Array = [ "crushing", "piercing", "explosion", "base" ];

    /* Resource types */
    public static const RESOURCE_WHITE :uint = 0;
    public static const RESOURCE_RED :uint = 1;
    public static const RESOURCE_BLUE :uint = 2;
    public static const RESOURCE_YELLOW :uint = 3;
    public static const RESOURCE__LIMIT :uint = 4;

    public static const RESOURCE_NAMES :Array = [ "white", "red", "blue", "yellow" ];

    /* Spells */
    public static const SPELL_TYPE_BLOODLUST :uint = 0;
    public static const SPELL_TYPE_RIGORMORTIS :uint = 1;

    public static const SPELL_NAMES :Array = [ "bloodlust", "rigormortis" ];

    /* Units */
    public static const UNIT_GRID_CELL_SIZE :int = 40;

    public static const UNIT_TYPE_GRUNT :uint = 0;
    public static const UNIT_TYPE_HEAVY :uint = 1;
    public static const UNIT_TYPE_SAPPER :uint = 2;
    public static const UNIT_TYPE_COLOSSUS :uint = 3;
    public static const UNIT_TYPE_COURIER :uint = 4;

    public static const UNIT_TYPE__CREATURE_LIMIT :uint = 5;

    public static const UNIT_TYPE_BASE :uint = UNIT_TYPE__CREATURE_LIMIT;

    public static const UNIT_NAMES :Array = [ "grunt", "heavy", "sapper", "colossus", "courier", "base" ];
    public static const CREATURE_UNIT_NAMES :Array = UNIT_NAMES.slice(0, UNIT_TYPE__CREATURE_LIMIT);
}

}
