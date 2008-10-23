package popcraft {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;

import popcraft.battle.*;
import popcraft.data.*;
import popcraft.util.*;

public class Constants
{
    /* Increment this whenever any cookie data changes. */
    public static const USER_COOKIE_VERSION :int = 1;

    /* ResourceManager stuff */
    public static const RESTYPE_LEVEL :String = "level";
    public static const RESTYPE_ENDLESS :String = "endlessLevel";
    public static const RESTYPE_GAMEDATA :String = "gameData";
    public static const RESTYPE_GAMEVARIANTS :String = "gameVariants";

    public static const RSRC_DEFAULTGAMEDATA :String = "defaultGameData";
    public static const RSRC_GAMEVARIANTS :String = "defaultGameVariants";

    // how many levels are available to players that haven't purchased the full game
    public static const NUM_FREE_SP_LEVELS :int = 7;
    public static const PREMIUM_SP_LEVEL_PACK_NAME :String = "incident_premium";
    public static const PREMIUM_SP_LEVEL_PACK_ID :int = 0; // TODO

    public static const SCREEN_SIZE :Vector2 = new Vector2(700, 500);
    public static const SOUND_MASTER_VOLUME :Number = 0.7;

    /* The handicap applied to a player who selected the Handicap option
    at the beginning of a multiplayer match. */
    public static const HANDICAPPED_MULTIPLIER :Number = 0.65;

    /* Debug options - these should all be false for a release. */
    public static const DEBUG_DRAW_STATS :Boolean = true;
    public static const DEBUG_ALLOW_CHEATS :Boolean = true;
    public static const DEBUG_DRAW_UNIT_DATA_CIRCLES :Boolean = false;
    public static const DEBUG_DRAW_AOE_ATTACK_RADIUS :Boolean = false;
    public static const DEBUG_DISABLE_MOVEMENT_SMOOTHING :Boolean = false;
    public static const DEBUG_GIVE_MORBID_INFECTION :Boolean = false;
    public static const DEBUG_DISABLE_AUDIO :Boolean = true;
    public static const DEBUG_SKIP_LEVEL_INTRO :Boolean = true;
    public static const DEBUG_UNLOCK_PREMIUM_CONTENT :Boolean = true;

    public static var DEBUG_LOAD_LEVELS_FROM_DISK :Boolean = false; // PopCraft_Standalone sets this to true

    /* Enums, etc */

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

    public static const TEAM_ARRANGEMENT_NAMES :Array =
        [ "1v1", "2v1", "1v1v1", "2v2", "3v1", "2v1v1", "1v1v1v1" ];
    public static const TEAM_ARRANGEMENT_PLAYER_COUNTS :Array = [ 2, 3, 3, 4, 4, 4, 4 ];

    /* Damage types */
    public static const DAMAGE_TYPE_CRUSHING :int = 0;
    public static const DAMAGE_TYPE_PIERCING :int = 1;
    public static const DAMAGE_TYPE_EXPLOSION :int = 2;
    public static const DAMAGE_TYPE_COLOSSUS :int = 3;

    public static const DAMAGE_TYPE_NAMES :Array =
        [ "crushing", "piercing", "explosion", "colossus" ];

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
    public static const CASTABLE_SPELL_TYPE__LIMIT :int = 3;
    public static const SPELL_TYPE_MULTIPLIER :int = 3;
    public static const SPELL_TYPE__LIMIT :int = 4;

    public static const SPELL_NAMES :Array =
        [ "rigormortis", "bloodlust", "shuffle", "multiplier" ];
    public static const CASTABLE_SPELL_NAMES :Array =
        SPELL_NAMES.slice(0, CASTABLE_SPELL_TYPE__LIMIT);
    public static const CREATURE_SPELL_NAMES :Array =
        CASTABLE_SPELL_NAMES.slice(0, CREATURE_SPELL_TYPE__LIMIT);

    public static const CASTABLE_SPELLS :Array =
        [ SPELL_TYPE_RIGORMORTIS, SPELL_TYPE_BLOODLUST, SPELL_TYPE_PUZZLERESET ];

    /* Units */
    public static const UNIT_TYPE_GRUNT :int = 0;
    public static const UNIT_TYPE_HEAVY :int = 1;
    public static const UNIT_TYPE_SAPPER :int = 2;
    public static const UNIT_TYPE_COURIER :int = 3;
    public static const UNIT_TYPE_COLOSSUS :int = 4;
    // creatures that can be created by players
    public static const UNIT_TYPE__PLAYER_CREATURE_LIMIT :int = 5;
    public static const UNIT_TYPE_BOSS :int = UNIT_TYPE__PLAYER_CREATURE_LIMIT;
    // creatures including those that are only created by the computer
    public static const UNIT_TYPE__CREATURE_LIMIT :int = UNIT_TYPE_BOSS + 1;
    public static const UNIT_TYPE_WORKSHOP :int = UNIT_TYPE__CREATURE_LIMIT;

    public static const UNIT_NAMES :Array =
        [ "grunt", "heavy", "sapper", "courier", "colossus", "boss", "workshop" ];

    public static const PLAYER_CREATURE_UNIT_NAMES :Array =
        UNIT_NAMES.slice(0, UNIT_TYPE__PLAYER_CREATURE_LIMIT);

    public static const CREATURE_UNIT_NAMES :Array = UNIT_NAMES.slice(0, UNIT_TYPE__CREATURE_LIMIT);

    /* Facing directions */
    public static const FACING_N :int = 0;
    public static const FACING_NW :int = 1;
    public static const FACING_SW :int = 2;
    public static const FACING_S :int = 3;
    public static const FACING_SE :int = 4;
    public static const FACING_NE :int = 5;

    public static const FACING_STRINGS :Array = [ "N", "NW", "SW", "S", "SE", "NE" ];

    /* Performance stuff */
    public static const BITMAP_LIVE_ANIM_THRESHOLDS :Array = [
        17,  // grunt
        29,  // heavy
        29,   // sapper
        29,   // courier
        22,  // colossus
        17,  // boss
    ];
    public static const BITMAP_DEATH_ANIM_THRESHOLDS :Array = [
        17,  // grunt
        17,  // heavy
        17,  // sapper
        17,  // courier
        17,  // colossus
        17,  // boss
    ];
}

}
