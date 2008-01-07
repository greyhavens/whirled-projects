package ghostbusters.fight.ouija {
    
import flash.display.DisplayObject;
import flash.display.Sprite;

import ghostbusters.fight.core.*;

public class Board extends AppObject
{
    public function Board()
    {
        _sprite.addChild(new IMAGE_BOARD());
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    public static function getSelectionIndexAt (loc :Vector2, epsilon :int) :int
    {
        var epsilonSquared :int = epsilon * epsilon;
        
        for (var i :int = 0; i < SELECTIONS.length / 2; ++i) {
            var selectionLoc :Vector2 = (SELECTIONS[i * 2] as Vector2);
            var delta :Vector2 = loc.clone();
            delta.subtract(selectionLoc);
            if (delta.lengthSquared <= epsilonSquared) {
                return i;
            }
        }
        
        return -1;
    }
    
    public static function selectionIndexToString (index :int) :String
    {
        index *= 2;
        if (index >= 0 && index < SELECTIONS.length) {
            return SELECTIONS[index + 1] as String;
        }
        
        return "";
    }
    
    protected var _sprite :Sprite = new Sprite();
    
    [Embed(source="../../../../rsrc/ouijaboard.png")]
    protected static const IMAGE_BOARD :Class;
    
    protected static const SELECTIONS :Array = [
        new Vector2(47, 117), "a",
        new Vector2(62, 107), "b",
        new Vector2(80, 101), "c",
        new Vector2(96, 96),  "d",
        new Vector2(111, 93), "e",
        new Vector2(125, 91), "f",
        new Vector2(142, 91), "g",
        new Vector2(159, 91), "h",
        new Vector2(173, 94), "i",
        new Vector2(182, 97), "j",
        new Vector2(195, 100), "k",
        new Vector2(212, 107), "l",
        new Vector2(225, 115), "m",
        new Vector2(54, 137), "n",
        new Vector2(70, 127), "o",
        new Vector2(84, 120), "p",
        new Vector2(100, 117), "q",
        new Vector2(115, 114), "r",
        new Vector2(128, 113), "s",
        new Vector2(139, 112), "t",
        new Vector2(154, 113), "u",
        new Vector2(170, 114), "v",
        new Vector2(187, 119), "w",
        new Vector2(203, 125), "x",
        new Vector2(216, 132), "y",
        new Vector2(228, 141), "z",
        
        new Vector2(63, 54),  "yes",
        new Vector2(217, 55), "no",
    ];
    
    protected static const A_INDEX :uint = 0;
    protected static const YES_INDEX :uint = 26;
    protected static const NO_INDEX :uint = 27;
    
}

}
