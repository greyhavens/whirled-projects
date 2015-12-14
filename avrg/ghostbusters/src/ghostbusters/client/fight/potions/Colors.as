package ghostbusters.client.fight.potions {
    
import com.whirled.contrib.simplegame.util.Rand;
        
public class Colors
{
    public static function getMixedColor (a :uint, b :uint) :uint
    {
        if (a == COLOR_CLEAR) {
            return b;
        } else if (b == COLOR_CLEAR) {
            return a;
        } else if (a == b) {
            // mixing a color with itself doesn't do anything
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
    
    public static const COLOR_CLEAR :uint = 0;
    
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
        new ColorData(0x004DFF, "blue"),
        
        new ColorData(0x1BE41B, "green"),
        new ColorData(0xAD00AD, "purple"),
        new ColorData(0xFF9D00, "orange"),
        
        new ColorData(0x744700, "brown"),
        
    ];
    
    /*
    public static function getMixedColor (components :Array) :uint
    {
        components.sort(
    }
    
    public static const COLOR_TRANSPARENT :uint = 0;
    
    // primaries
    public static const COLOR_CLEAR :uint = 1;
    public static const COLOR_BLACK :uint = 2;
    public static const COLOR_RED :uint = 3;
    public static const COLOR_YELLOW :uint = 4;
    public static const COLOR_BLUE :uint = 5;
    
    // secondaries
    public static const COLOR_GREEN :uint = 6;
    public static const COLOR_PURPLE :uint = 7;
    public static const COLOR_ORANGE :uint = 8;
    
    public static const COLOR_LTRED :uint = 9;
    public static const COLOR_DKRED :uint = 10;
    public static const COLOR_LTYELLOW :uint = 11;
    public static const COLOR_DKYELLOW :uint = 12;
    public static const COLOR_LTBLUE :uint = 13;
    public static const COLOR_DKBLUE :uint = 14;
    
    public static const COLOR_LTGREEN :uint = 15;
    public static const COLOR_DKGREEN :uint = 16;
    public static const COLOR_LTPURPLE :uint = 17;
    public static const COLOR_DKPURPLE :uint = 18;
    public static const COLOR_LTORANGE :uint = 19;
    public static const COLOR_DKORANGE :uint = 20;
    
    // other
    public static const COLOR_FAIL :uint = 21;
    
    public static const COLOR__LIMIT :uint = 22;
    
    public static const COLOR__PRIMARY_FIRST :uint = COLOR_CLEAR;
    public static const COLOR__PRIMARY_LIMIT :uint = COLOR_BLUE + 1;
    public static const COLOR__SECONDARY_FIRST :uint = COLOR_GREEN;
    public static const COLOR__SECONDARY_LIMIT :uint = COLOR_DKORANGE + 1;
    
    public static const MIXTURES :Array = [
    
        [],  // transparent
        
        [ COLOR_CLEAR ],    // white
        [ COLOR_BLACK ],    // black
        
        [ COLOR_RED ],      // red
        [ COLOR_YELLOW ],   // yellow
        [ COLOR_BLUE ],     // blue
        
        [ COLOR_YELLOW, COLOR_BLUE ],   // green
        [ COLOR_RED, COLOR_BLUE ], // purple
        [ COLOR_RED, COLOR_YELLOW ], // orange
        
        [ COLOR_CLEAR, COLOR_RED ], // light red
        [ COLOR_BLACK, COLOR_RED ], // dark red
        [ COLOR_CLEAR, COLOR_YELLOW ], // light yellow
        [ COLOR_BLACK, COLOR_YELLOW ], // dark yellow
        [ COLOR_CLEAR, COLOR_BLUE ], // light blue
        [ COLOR_BLACK, COLOR_BLUE ], // dark blue
        
        [ COLOR_CLEAR, COLOR_YELLOW, COLOR_BLUE ], // light green
        [ COLOR_BLACK, COLOR_YELLOW, COLOR_BLUE ], // dark green
        [ COLOR_CLEAR, COLOR_RED, COLOR_BLUE ], // light purple
        [ COLOR_BLACK, COLOR_RED, COLOR_BLUE ], // dark purple
        [ COLOR_CLEAR, COLOR_RED, COLOR_YELLOW ], // light orange
        [ COLOR_BLACK, COLOR_RED, COLOR_YELLOW ], // dark orange
        
    ];
    
    */
}

}