package popcraft {

import popcraft.battle.*;

import com.threerings.util.Assert;
import flash.geom.Point;

public class Constants
{
    /* Images */
    [Embed(source="../../rsrc/melee.png")]
    public static const IMAGE_MELEE :Class;

    [Embed(source="../../rsrc/base.png")]
    public static const IMAGE_BASE :Class;

    /* Puzzle stuff */
    public static const PIECE_CLEAR_TIMER_LENGTH :Number = 0.75;

    public static const MIN_GROUP_SIZE :int = 1; // no min group size right now

    public static const PUZZLE_COLS :int = 5;
    public static const PUZZLE_ROWS :int = 8;
    public static const PUZZLE_TILE_SIZE :int = 40;

    /* Battle stuff */
    public static const BATTLE_COLS :int = 15;
    public static const BATTLE_ROWS :int = 15;
    public static const BATTLE_TILE_SIZE :int = 32;
    public static const BASE_MAX_HEALTH :int = 100;

    /* Resource types */

    // wow, I miss enums
    public static const RESOURCE_WOOD :uint = 0;
    public static const RESOURCE_GOLD :uint = 1;
    public static const RESOURCE_MANA :uint = 2;
    public static const RESOURCE_MORALE :uint = 3;
    public static const RESOURCE__LIMIT :uint = 4;

    public static const RESOURCE_TYPES :Array = [
        new ResourceType("wood", 0x885300),
        new ResourceType("gold", 0xF8F500),
        new ResourceType("mana", 0x00F8EF),
        new ResourceType("morale", 0xFF77BA)
    ];

    public static function getResource (type :uint) :ResourceType {
        Assert.isTrue(type < RESOURCE_TYPES.length);
        return (RESOURCE_TYPES[type] as ResourceType);
    }

    public static const UNIT_MELEE :uint = 0;
    public static const UNIT__LIMIT :uint = 1;

    public static const UNIT_DATA :Array = [
                                 // wood, gold, mana, morale
            new UnitData( "melee", [5,   0,  0,    0], IMAGE_MELEE )
    ];

    public static const CLEAR_VALUE_TABLE :IntValueTable =
        new IntValueTable( [-20, -10, 10, 20, 30, 20] );
             // group size:   1,   2,  3,  4,  5,  6+ = 50, 70, 90, ...

    /* Screen layout */
    public static const RESOURCE_DISPLAY_LOC :Point = new Point(0, 0);
    public static const PUZZLE_BOARD_LOC :Point = new Point(0, 50);
    public static const BATTLE_BOARD_LOC :Point = new Point(220, 20);

    public static const UNIT_BUTTON_LOCS :Array = [
        new Point(0, 400)
    ];

    public static function getPlayerBaseLocations (numPlayers :uint) :Array // of Points
    {
        switch (numPlayers) {
        case 2:
            return [ new Point(28, 240), new Point(452, 240) ];

        default:
            return [];
        }
    }
}

}
