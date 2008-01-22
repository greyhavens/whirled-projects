package ghostbusters.fight.potions {
    
import com.whirled.contrib.core.util.Rand;
        
public class Colors
{
    public static function getMixedColor (a :uint, b :uint) :uint
    {
        // mixing a color with itself doesn't do anything
        if (a == b) {
            return a;
        } else if (hasColor(COLOR_RED)) {
            if (hasColor(COLOR_YELLOW)) {
                return COLOR_ORANGE;
            } else if (hasColor(COLOR_BLUE)) {
                return COLOR_PURPLE;
            }
        } else if (hasColor(COLOR_YELLOW)) {
            if (hasColor(COLOR_BLUE)) {
                return COLOR_GREEN;
            }
        }
        
        return COLOR_BROWN;
        
        function hasColor (c :uint) :Boolean
        {
            return (a == c || b == c);
        }
    }
    
    public static const COLOR_WHITE :uint = 0;
    
    // primaries
    public static const COLOR_RED :uint = 1;
    public static const COLOR_YELLOW :uint = 2;
    public static const COLOR_BLUE :uint = 3;
    
    // secondaries
    public static const COLOR_GREEN :uint = 4;
    public static const COLOR_PURPLE :uint = 5;
    public static const COLOR_ORANGE :uint = 6;
    
    public static const COLOR_BROWN :uint = 7;
    
    public static const COLOR__LIMIT :uint = 8;
    public static const COLOR__PRIMARY_FIRST :uint = COLOR_RED;
    public static const COLOR__PRIMARY_LIMIT :uint = COLOR_BLUE + 1;
    public static const COLOR__SECONDARY_FIRST :uint = COLOR_GREEN;
    public static const COLOR__SECONDARY_LIMIT :uint = COLOR_ORANGE + 1;
    
    public static function getRandomPrimary () :uint
    {
        return Rand.nextIntRange(COLOR__PRIMARY_FIRST, COLOR__PRIMARY_LIMIT, Rand.STREAM_COSMETIC);
    }
    
    public static function getRandomSecondary () :uint
    {
        return Rand.nextIntRange(COLOR__SECONDARY_FIRST, COLOR__SECONDARY_LIMIT, Rand.STREAM_COSMETIC);
    }
    
    public static function getScreenColor (color :uint) :uint
    {
        return (COLOR_DATA[color] as ColorData).screenColor;
    }
    
    public static function getColorName (color :uint) :String
    {
        return (COLOR_DATA[color] as ColorData).colorName;
    }
    
    protected static const COLOR_DATA :Array = [
    
        new ColorData(0xFFFFFF, "white"),
        
        new ColorData(0xFF0000, "red"),
        new ColorData(0xFFFF00, "yellow"),
        new ColorData(0x0000FF, "blue"),
        
        new ColorData(0x00FF00, "green"),
        new ColorData(0xAD00AD, "purple"),
        new ColorData(0xFF9D00, "orange"),
        
        new ColorData(0x744700, "brown"),
        
    ];
}

}