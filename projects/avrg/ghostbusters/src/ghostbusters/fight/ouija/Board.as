package ghostbusters.fight.ouija {
    
import flash.display.Sprite;

import ghostbusters.fight.core.*;

[SWF(width="280", height="222", frameRate="30")]
public class Board extends Sprite
{
    public function Board()
    {
    }
    
    /* Images */
    [Embed(source="../../../../rsrc/ouijaboard.png")]
    protected static const IMAGE_BOARD :Class;
    
    protected static const BOARD_LOCS :Array = [
        new Vector2(47, 117),   // A
        new Vector2(62, 107),   // B
        new Vector2(80, 101),   // C
        new Vector2(96, 96),   // D
        new Vector2(111, 93),   // E
        new Vector2(125, 91),   // F
        new Vector2(142, 91),   // G
        new Vector2(159, 91),   // H
        new Vector2(173, 94),   // I
        new Vector2(182, 97),   // J
        new Vector2(195, 100),   // K
        new Vector2(212, 107),   // L
        new Vector2(225, 115),   // M
        new Vector2(54, 137),   // N
        new Vector2(70, 127),   // O
        new Vector2(84, 120),   // P
        new Vector2(100, 117),   // Q
        new Vector2(115, 114),   // R
        new Vector2(128, 113),   // S
        new Vector2(139, 112),   // T
        new Vector2(154, 113),   // U
        new Vector2(170, 114),   // V
        new Vector2(187, 119),   // W
        new Vector2(203, 125),   // X
        new Vector2(216, 132),   // Y
        new Vector2(228, 141),   // Z
        
        new Vector2(63, 54),    // YES
        new Vector2(217, 55)    // NO
    ];
    
    protected static const A_INDEX :uint = 0;
    protected static const YES_INDEX :uint = 26;
    protected static const NO_INDEX :uint = 27;
}

}
