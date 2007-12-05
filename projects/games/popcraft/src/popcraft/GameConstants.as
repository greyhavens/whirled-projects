package popcraft {

import com.threerings.util.Assert;

public class GameConstants
{
    public static const PIECE_CLEAR_TIMER_LENGTH :Number = 0.75;

    public static const BOARD_COLS :int = 5;
    public static const BOARD_ROWS :int = 8;
    public static const BOARD_CELL_SIZE :int = 40;

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
}

}
