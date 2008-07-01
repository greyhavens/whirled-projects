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
    public static const SCREEN_SIZE :Vector2 = new Vector2(700, 500);
    public static const SOUND_MASTER_VOLUME :Number = 0.7;

    /* The handicap applied to a player who selected the Handicap option
    at the beginning of a multiplayer match. */
    public static const HANDICAPPED_MULTIPLIER :Number = 0.65;

    /* Debug options */
    public static const DEBUG_DRAW_STATS :Boolean = true;
    public static const DEBUG_CHECKSUM_STATE :int = 0;
    public static const DEBUG_ALLOW_CHEATS :Boolean = true;
    public static const DEBUG_DRAW_UNIT_DATA_CIRCLES :Boolean = false;
    public static const DEBUG_DRAW_AOE_ATTACK_RADIUS :Boolean = false;
    public static const DEBUG_DISABLE_MOVEMENT_SMOOTHING :Boolean = false;
    public static const DEBUG_DISABLE_DIURNAL_CYCLE :Boolean = false;
    public static const DEBUG_LOAD_LEVELS_FROM_DISK :Boolean = false;

    /* Screen layout */
    public static const DASHBOARD_LOC :Point = new Point(350, 430);

    public static const PUZZLE_BOARD_LOC :Point = new Point(-131, -63);
    public static const DIURNAL_METER_LOC :Point = new Point(0, 0);
    public static const UNIT_AND_SPELL_DESCRIPTION_BR_LOC :Point = new Point(200, 378);

    public static const FIRST_SPELL_BUTTON_LOC :Point = new Point(220, 320);

    /* Puzzle stuff */
    public static const PUZZLE_HEIGHT :int = 110;

    public static const PUZZLE_COLS :int = 12;
    public static const PUZZLE_ROWS :int = 5;

    public static const PUZZLE_TILE_SIZE :int = int(PUZZLE_HEIGHT / PUZZLE_ROWS) + 1;

    /* Battle stuff */
    public static const BATTLE_WIDTH :int = 700;
    public static const BATTLE_HEIGHT :int = 372;

    public static const PHASE_DAY :int = 0;
    public static const PHASE_NIGHT :int = 1;
    public static const PHASE_ECLIPSE :int = 2;

    public static const DAY_PHASE_NAMES :Array = [ "day", "night", "eclipse" ];

    public static const ARRANGE_1V1 :int = 0;
    public static const ARRANGE_2V1 :int = 1;
    public static const ARRANGE_1V1V1 :int = 2;
    public static const ARRANGE_2V2 :int = 3;
    public static const ARRANGE_3V1 :int = 4;
    public static const ARRANGE_2V1V1 :int = 5;
    public static const ARRANGE_1V1V1V1 :int = 6;

    public static const TEAM_ARRANGEMENT_NAMES :Array = [ "1v1", "2v1", "1v1v1", "2v2", "3v1", "2v1v1", "1v1v1v1" ];
    public static const TEAM_ARRANGEMENT_PLAYER_COUNTS :Array = [ 2, 3, 3, 4, 4, 4, 4 ];

    /* Damage types */
    public static const DAMAGE_TYPE_CRUSHING :int = 0;
    public static const DAMAGE_TYPE_PIERCING :int = 1;
    public static const DAMAGE_TYPE_EXPLOSION :int = 2;
    public static const DAMAGE_TYPE_COLOSSUS :int = 3;
    public static const DAMAGE_TYPE_BASE :int = 4; // bases damage units that attack them

    public static const DAMAGE_TYPE_NAMES :Array = [ "crushing", "piercing", "explosion", "colossus", "base" ];

    /* Resource types */
    public static const RESOURCE_WHITE :int = 0;
    public static const RESOURCE_RED :int = 1;
    public static const RESOURCE_BLUE :int = 2;
    public static const RESOURCE_YELLOW :int = 3;
    public static const RESOURCE__LIMIT :int = 4;

    public static const RESOURCE_NAMES :Array = [ "white", "red", "blue", "yellow" ];

    /* Spells */
    public static const SPELL_TYPE_RIGORMORTIS :int = 0;
    public static const SPELL_TYPE_BLOODLUST :int = 1;

    public static const CREATURE_SPELL_TYPE__LIMIT :int = 2;

    public static const SPELL_TYPE_PUZZLERESET :int = 2;

    public static const SPELL_TYPE__LIMIT :int = 3;

    public static const SPELL_NAMES :Array = [ "rigormortis", "bloodlust", "shuffle" ];
    public static const CREATURE_SPELL_NAMES :Array = SPELL_NAMES.slice(0, CREATURE_SPELL_TYPE__LIMIT);

    /* Units */
    public static const UNIT_TYPE_GRUNT :int = 0;
    public static const UNIT_TYPE_HEAVY :int = 1;
    public static const UNIT_TYPE_SAPPER :int = 2;
    public static const UNIT_TYPE_COURIER :int = 3;
    public static const UNIT_TYPE_COLOSSUS :int = 4;
    public static const UNIT_TYPE__PLAYER_CREATURE_LIMIT :int = 5; // creatures that can be created by players
    public static const UNIT_TYPE_BOSS :int = UNIT_TYPE__PLAYER_CREATURE_LIMIT;
    public static const UNIT_TYPE__CREATURE_LIMIT :int = UNIT_TYPE_BOSS + 1;   // creatures including those that are only created by the computer
    public static const UNIT_TYPE_BASE :int = UNIT_TYPE__CREATURE_LIMIT;

    public static const UNIT_NAMES :Array = [ "grunt", "heavy", "sapper", "courier", "colossus", "boss", "base" ];
    public static const PLAYER_CREATURE_UNIT_NAMES :Array = UNIT_NAMES.slice(0, UNIT_TYPE__PLAYER_CREATURE_LIMIT);
    public static const CREATURE_UNIT_NAMES :Array = UNIT_NAMES.slice(0, UNIT_TYPE__CREATURE_LIMIT);

    /* Facing directions */
    public static const FACING_N :int = 0;
    public static const FACING_NW :int = 1;
    public static const FACING_SW :int = 2;
    public static const FACING_S :int = 3;
    public static const FACING_SE :int = 4;
    public static const FACING_NE :int = 5;

    public static const FACING_STRINGS :Array = [ "N", "NW", "SW", "S", "SE", "NE" ];
}

}
