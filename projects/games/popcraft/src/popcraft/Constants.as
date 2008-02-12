package popcraft {

import com.threerings.util.Assert;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.geom.Point;

import popcraft.battle.*;
import popcraft.util.*;

public class Constants
{
    public static const SCREEN_DIMS :Vector2 = new Vector2(700, 500);

    public static const DEBUG_LEVEL :int = 0;
    public static const CHEATS_ENABLED :Boolean = true;
    public static const DRAW_UNIT_DATA_CIRCLES :Boolean = true;

    public static const PLAYER_COLORS :Array = [
       uint(0xFFFF0000),
       uint(0xFF9FBCFF),
       uint(0xFF51FF7E),
       uint(0xFFFFE75F)
    ];

    /* Puzzle stuff */
    public static const PIECE_CLEAR_TIMER_LENGTH :Number = 0.75;

    public static const MIN_GROUP_SIZE :int = 1; // no min group size right now

    public static const PUZZLE_COLS :int = 8;
    public static const PUZZLE_ROWS :int = 4;
    public static const PUZZLE_TILE_SIZE :int = 28;

    public static const CLEAR_VALUE_TABLE :IntValueTable =
        new IntValueTable( [-20, -10, 10, 20, 30, 20] );
             // group size:   1,   2,  3,  4,  5,  6+ = 50, 70, 90, ...

    /* Battle stuff */
    public static const BATTLE_WIDTH :int = 700;
    public static const BATTLE_HEIGHT :int = 372;

    /* Damage types */
    public static const DAMAGE_TYPE_CRUSHING :uint = 0;
    public static const DAMAGE_TYPE_PIERCING :uint = 1;
    public static const DAMAGE_TYPE_BASE :uint = 2; // bases damage units that attack them

    /* Resource types */

    // wow, I miss enums
    public static const RESOURCE_BROWN :uint = 0;
    public static const RESOURCE_GOLD :uint = 1;
    public static const RESOURCE_BLUE :uint = 2;
    public static const RESOURCE_PINK :uint = 3;
    public static const RESOURCE__LIMIT :uint = 4;

    public static const RESOURCE_TYPES :Array = [
        new ResourceType("brown", 0xCF7A00, 1),
        new ResourceType("gold", 0xF8F500, 0.5),
        new ResourceType("blue", 0x00F8EF, 1),
        new ResourceType("pink", 0xFF77BA, 0.5)
    ];

    public static function getResource (type :uint) :ResourceType {
        Assert.isTrue(type < RESOURCE_TYPES.length);
        return (RESOURCE_TYPES[type] as ResourceType);
    }

    /* Units */

    public static const UNIT_TYPE_GRUNT :uint = 0;
    public static const UNIT_TYPE_HEAVY :uint = 1;
    public static const UNIT_TYPE_SAPPER :uint = 2;

    public static const UNIT_TYPE__CREATURE_LIMIT :uint = 3;

    public static const UNIT_TYPE_BASE :uint = 3;

    public static const UNIT_CLASS_GROUND :uint = (1 << 0);
    public static const UNIT_CLASS_AIR :uint = (1 << 1);
    public static const UNIT_CLASS__ALL :uint = (0xFFFFFFFF);

    public static const UNIT_DATA :Array = [

            new UnitData (
                "grunt"                     // name
                , [25,   25,  0,   0]        // resource costs (brown, gold, blue, pink)
                , -1, new IntRange(0, 0)   // wanderEvery, wanderRange
                , 25                        // move speed (pixels/second)
                , 100                       // health
                , new UnitArmor( [DAMAGE_TYPE_CRUSHING, 0.8, DAMAGE_TYPE_PIERCING, 0.7, DAMAGE_TYPE_BASE, 0.8] )   // armor
                , [ new UnitWeapon(UnitWeapon.TYPE_MELEE, DAMAGE_TYPE_CRUSHING, new NumRange(10, 10, Rand.STREAM_GAME), UNIT_CLASS_GROUND, 1, 35, 0) ] // weapons
                , 15                        // collision radius
                , 40                        // detect radius
                , 180                       // lose interest radius
            )

            ,

            new UnitData (
                "heavy"                     // name
                , [0,   0,  25,   25]        // resource costs (brown, gold, blue, pink)
                , -1, new IntRange(0, 0)    // wanderEvery, wanderRange
                , 25                        // move speed (pixels/second)
                , 100                       // health
                , new UnitArmor( [DAMAGE_TYPE_CRUSHING, 1, DAMAGE_TYPE_PIERCING, 1, DAMAGE_TYPE_BASE, 1] )   // armor
                , [ 
                    new UnitWeapon(UnitWeapon.TYPE_MELEE, DAMAGE_TYPE_CRUSHING, new NumRange(10, 10, Rand.STREAM_GAME), UNIT_CLASS__ALL, 1, 50, 0),
                    new UnitWeapon(UnitWeapon.TYPE_MISSILE, DAMAGE_TYPE_PIERCING, new NumRange(10, 10, Rand.STREAM_GAME), UNIT_CLASS__ALL, 1, 200, 300),
                  ]
                , 14                        // collision radius
                , 200                        // detect radius
                , 180                       // lose interest radius
            )

            ,

            new UnitData (
                "sapper"                     // name
                , [0,   15,  0,   15]        // resource costs (brown, gold, blue, pink)
                , -1, new IntRange(0, 0)    // wanderEvery, wanderRange
                , 40                        // move speed (pixels/second)
                , 100                       // health
                , new UnitArmor( [DAMAGE_TYPE_CRUSHING, 1, DAMAGE_TYPE_PIERCING, 1, DAMAGE_TYPE_BASE, 1] )   // armor
                , [ new UnitWeapon(UnitWeapon.TYPE_MELEE, DAMAGE_TYPE_CRUSHING, new NumRange(10, 10, Rand.STREAM_GAME), UNIT_CLASS__ALL, 1, 50, 0) ] // weapons
                , 15                        // collision radius
                , 15                        // detect radius
                , 180                       // lose interest radius
            )

            ,

            // non-creature units must come after creature units

            new UnitData (
                "base"                      // name
                , [0,   0,  0,    0]        // resource costs (brown, gold, blue, pink)
                , -1, new IntRange(0, 0)    // wanderEvery, wanderRange
                , 0                         // move speed (pixels/second)
                , 100                       // health
                , new UnitArmor( [DAMAGE_TYPE_CRUSHING, 0.1, DAMAGE_TYPE_PIERCING, 0.1] )   // armor
                , [ new UnitWeapon(UnitWeapon.TYPE_MELEE, DAMAGE_TYPE_BASE, new NumRange(20, 20, Rand.STREAM_GAME), UNIT_CLASS__ALL, 0, 1000, 0) ] // weapons
                , 40                        // collision radius
                , 40                        // detect radius
                , 180                       // lose interest radius
            )
    ];

    /* Screen layout */
    public static const RESOURCE_DISPLAY_LOC :Point = new Point(286, 5);
    public static const PUZZLE_BOARD_LOC :Point = new Point(10, 3);
    public static const BATTLE_BOARD_LOC :Point = new Point(0, 115);

    public static const FIRST_UNIT_BUTTON_LOC :Point = new Point(286, 25);

    public static function getPlayerBaseLocations (numPlayers :uint) :Array // of Vector2s
    {
        // return an array of Vector2 pairs - for each player, a base loc and an initial waypoint loc

        switch (numPlayers) {
        case 1: 
            return [ new Vector2(50, 315) ]; // we don't have 1-player games except during development
            break;
            
        case 2:
            return [
                new Vector2(50, 315),   // bottom left
                new Vector2(652, 70),   // top right
             ];
             break;

        case 3:
            return [
                new Vector2(48, 68),       // top left
                new Vector2(28, 452),     // bottom left
                new Vector2(452, 250),    // middle right
            ];
            break;

        case 4:
            return [
                new Vector2(48, 68),    // top left
                new Vector2(48, 452),   // bottom left
                new Vector2(452, 68),   // top right
                new Vector2(452, 452),  // bottom right
            ];
            break;

        default:
            return [];
            break;
        }
    }
}

}
