package popcraft {

import com.threerings.util.Assert;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.geom.Point;

import popcraft.util.*;
import popcraft.battle.*;

public class Constants
{
    public static const SCREEN_DIMS :Vector2 = new Vector2(700, 500);

    public static const DEBUG_LEVEL :int = 0;
    public static const CHEATS_ENABLED :Boolean = true;

    public static const PLAYER_COLORS :Array = [
       uint(0xFFFF0000),
       uint(0xFF9FBCFF),
       uint(0xFF51FF7E),
       uint(0xFFFFE75F)
    ];

    /* Images */
    [Embed(source="../../rsrc/melee.png")]
    public static const IMAGE_MELEE :Class;

    [Embed(source="../../rsrc/ranged.png")]
    public static const IMAGE_RANGED :Class;

    [Embed(source="../../rsrc/base.png")]
    public static const IMAGE_BASE :Class;

    [Embed(source="../../rsrc/waypoint.png")]
    public static const IMAGE_WAYPOINT :Class;

    [Embed(source="../../rsrc/city_bg.png")]
    public static const IMAGE_BATTLE_BG :Class;

    [Embed(source="../../rsrc/city_forefront.png")]
    public static const IMAGE_BATTLE_FG :Class;

    /* Puzzle stuff */
    public static const PIECE_CLEAR_TIMER_LENGTH :Number = 0.75;

    public static const MIN_GROUP_SIZE :int = 1; // no min group size right now

    public static const PUZZLE_COLS :int = 4;
    public static const PUZZLE_ROWS :int = 8;
    public static const PUZZLE_TILE_SIZE :int = 40;

    public static const CLEAR_VALUE_TABLE :IntValueTable =
        new IntValueTable( [-20, -10, 10, 20, 30, 20] );
             // group size:   1,   2,  3,  4,  5,  6+ = 50, 70, 90, ...

    /* Battle stuff */
    public static const BATTLE_COLS :int = 15;
    public static const BATTLE_ROWS :int = 15;
    public static const BATTLE_TILE_SIZE :int = 32;

    /* Damage types */
    public static const DAMAGE_TYPE_MELEE :uint = 0;
    public static const DAMAGE_TYPE_PROJECTILE :uint = 1;
    public static const DAMAGE_TYPE_BASE :uint = 2; // bases damage units that attack them

    /* Resource types */

    // wow, I miss enums
    public static const RESOURCE_BROWN :uint = 0;
    public static const RESOURCE_GOLD :uint = 1;
    public static const RESOURCE_BLUE :uint = 2;
    public static const RESOURCE_PINK :uint = 3;
    public static const RESOURCE__LIMIT :uint = 4;

    public static const RESOURCE_TYPES :Array = [
        new ResourceType("brown", 0xCF7A00),
        new ResourceType("gold", 0xF8F500),
        new ResourceType("blue", 0x00F8EF),
        new ResourceType("pink", 0xFF77BA)
    ];

    public static function getResource (type :uint) :ResourceType {
        Assert.isTrue(type < RESOURCE_TYPES.length);
        return (RESOURCE_TYPES[type] as ResourceType);
    }

    /* Units */

    public static const UNIT_TYPE_GRUNT :uint = 0;
    public static const UNIT_TYPE_RANGED :uint = 1;

    public static const UNIT_TYPE__CREATURE_LIMIT :uint = 2;

    public static const UNIT_TYPE_BASE :uint = 2;

    public static const UNIT_CLASS_GROUND :uint = (1 << 0);
    public static const UNIT_CLASS_AIR :uint = (1 << 1);
    public static const UNIT_CLASS__ALL :uint = (0xFFFFFFFF);

    public static const UNIT_DATA :Array = [

            new UnitData (
                "melee"                     // name
                , [25,   25,  0,   0]        // resource costs (brown, gold, blue, pink)
                , IMAGE_MELEE               // image
                , -1, new IntRange(0, 0)   // wanderEvery, wanderRange
                , 64                        // move speed (pixels/second)
                , 100                       // health
                , new UnitArmor( [DAMAGE_TYPE_MELEE, 0.8, DAMAGE_TYPE_PROJECTILE, 0.7, DAMAGE_TYPE_BASE, 0.8] )   // armor
                , new UnitAttack(DAMAGE_TYPE_MELEE, new NumRange(10, 10), UNIT_CLASS_GROUND, 1, 35) // attack
                , 30                        // collision radius
                , 90                        // detect radius
                , 180                       // lose interest radius
            )

            ,

            new UnitData (
                "ranged"                    // name
                , [0,   0,  25,   25]        // resource costs (brown, gold, blue, pink)
                , IMAGE_RANGED              // image
                , -1, new IntRange(0, 0)    // wanderEvery, wanderRange
                , 40                        // move speed (pixels/second)
                , 100                       // health
                , new UnitArmor( [DAMAGE_TYPE_MELEE, 1, DAMAGE_TYPE_PROJECTILE, 1, DAMAGE_TYPE_BASE, 1] )   // armor
                , new UnitAttack(DAMAGE_TYPE_PROJECTILE, new NumRange(10, 10), UNIT_CLASS__ALL, 1, 50) // attack
                , 30                        // collision radius
                , 90                        // detect radius
                , 180                       // lose interest radius
            )

            ,

            // non-creature units must come after creature units

            new UnitData (
                "base"                      // name
                , [0,   0,  0,    0]        // resource costs (brown, gold, blue, pink)
                , IMAGE_BASE                // image
                , -1, new IntRange(0, 0)    // wanderEvery, wanderRange
                , 0                         // move speed (pixels/second)
                , 100                       // health
                , new UnitArmor( [DAMAGE_TYPE_MELEE, 0.1, DAMAGE_TYPE_PROJECTILE, 0.1] )   // armor
                , new UnitAttack(DAMAGE_TYPE_BASE, new NumRange(20, 20), UNIT_CLASS__ALL, 0, 1000) // attack
                , 60                        // collision radius
                , 90                        // detect radius
                , 180                       // lose interest radius
            )
    ];

    /* Screen layout */
    public static const RESOURCE_DISPLAY_LOC :Point = new Point(0, 0);
    public static const PUZZLE_BOARD_LOC :Point = new Point(20, 50);
    public static const BATTLE_BOARD_LOC :Point = new Point(200, 0);

    public static const UNIT_BUTTON_LOCS :Array = [
        new Point(0, 400),
        new Point(50, 400)
    ];

    public static function getPlayerBaseLocations (numPlayers :uint) :Array // of Vector2s
    {
        // return an array of Vector2 pairs - for each player, a base loc and an initial waypoint loc

        switch (numPlayers) {
        case 2:
            return [
                new Vector2(28, 250), new Vector2(75, 250),     // middle left
                new Vector2(452, 250), new Vector2(405, 250)    // middle right
             ];
             break;

        case 3:
            return [
                new Vector2(48, 68), new Vector2(75, 115),       // top left
                new Vector2(28, 452), new Vector2(75, 405),     // bottom left
                new Vector2(452, 250), new Vector2(405, 250)    // middle right
            ];
            break;

        case 4:
            return [
                new Vector2(48, 68), new Vector2(75, 115),       // top left
                new Vector2(48, 452), new Vector2(75, 405),     // bottom left
                new Vector2(452, 68), new Vector2(405, 115),     // top right
                new Vector2(452, 452), new Vector2(405, 405),   // bottom right
            ];
            break;

        default:
            return [];
            break;
        }
    }
}

}
