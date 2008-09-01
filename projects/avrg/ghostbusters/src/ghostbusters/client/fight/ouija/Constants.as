package ghostbusters.client.fight.ouija {
    
import com.threerings.flash.Vector2;

public class Constants
{
    public static const PICTO_MINLINELENGTH :Number = 6;
    public static const PICTO_LINEWIDTH :Number = 8;
    public static const PICTO_TARGETRADIUS :Number = 8;
    public static const PICTO_MAXAVGDISTANCE :Number = 5;
    
    public static const PICTO_PICTURES :Array = [
    
        // up, right, down
        [
            new Vector2(96, 168),
            new Vector2(96, 95),
            new Vector2(174, 95),
            new Vector2(174, 165),
        ],
        
        // steps
        [
            new Vector2(93, 173),
            new Vector2(93, 139),
            new Vector2(124, 143),
            new Vector2(125, 110),
            new Vector2(161, 109),
            new Vector2(159, 142),
            new Vector2(196, 141),
            new Vector2(196, 173),
        ],
        
        // squiggle
        [
            new Vector2(102, 174),
            new Vector2(102, 122),
            new Vector2(162, 123),
            new Vector2(163, 156),
            new Vector2(129, 153),
            new Vector2(126, 91),
            new Vector2(202, 92),
        ],
        
        // spiral
        [
            new Vector2(102, 173),
            new Vector2(100, 96),
            new Vector2(194, 96),
            new Vector2(196, 174),
            new Vector2(124, 172),
            new Vector2(124, 117),
            new Vector2(170, 118),
            new Vector2(168, 152),
            new Vector2(146, 151),
            new Vector2(146, 136),
        ],
        
        // M
        [
            new Vector2(95, 165),
            new Vector2(94, 100),
            new Vector2(126, 100),
            new Vector2(128, 136),
            new Vector2(163, 136),
            new Vector2(162, 101),
            new Vector2(191, 101),
            new Vector2(194, 165),
        ],
        
        // half clover
        [
            new Vector2(90, 114),
            new Vector2(183, 113),
            new Vector2(181, 75),
            new Vector2(139, 72),
            new Vector2(137, 172),
            new Vector2(185, 174),
            new Vector2(182, 141),
            new Vector2(91, 143),
        ],
        
    ];
}

}