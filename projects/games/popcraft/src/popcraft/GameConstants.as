package popcraft {

import com.threerings.util.Assert;
import flash.geom.Point;

public class GameConstants
{
    public static const RESOURCE_DISPLAY_LOC :Point = new Point(100, 0);
    public static const PUZZLE_LOC :Point = new Point(0, 50);
    public static const BATTLE_LOC :Point = new Point(220, 20);

    public static const MELEE_BUTTON_LOC :Point = new Point(0, 400);

    public static const PIECE_CLEAR_TIMER_LENGTH :Number = 0.75;

    public static const MIN_GROUP_SIZE :int = 1; // no min group size right now

    public static const PUZZLE_COLS :int = 5;
    public static const PUZZLE_ROWS :int = 8;
    public static const PUZZLE_TILE_SIZE :int = 40;

    public static const BATTLE_COLS :int = 15;
    public static const BATTLE_ROWS :int = 12;
    public static const BATTLE_TILE_SIZE :int = 32;

    // Resource types

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

    public static const CREATURE_MELEE :uint = 0;
    public static const CREATURE__LIMIT :uint = 1;

    public static const CREATURE_DATA :Array = [
                                 // wood, gold, mana, morale
        new CreatureData( "melee", [5,   0,  0,    0] )
    ];

    public static const CLEAR_VALUE_TABLE :IntValueTable =
        new IntValueTable( [-20, -10, 10, 20, 30, 20] );
             // group size:   1,   2,  3,  4,  5,  6+ = 50, 70, 90, ...
}

}
