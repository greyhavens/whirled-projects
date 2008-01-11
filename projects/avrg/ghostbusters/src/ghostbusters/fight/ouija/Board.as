package ghostbusters.fight.ouija {

import flash.display.DisplayObject;
import flash.display.Sprite;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.util.Rand;

public class Board extends SceneObject
{
    public function Board()
    {
        _sprite.addChild(new Content.SWF_BOARD());
        _sprite.mouseChildren = false;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public static function getSelectionIndexAt (loc :Vector2, epsilon :int) :int
    {
        for (var i :uint = 0; i < SELECTIONS.length / 2; ++i) {
            if (pointIntersectsSelection(loc, epsilon, i)) {
                return i;
            }
        }

        return -1;
    }

    public static function pointIntersectsSelection (loc :Vector2, epsilon :int, selectionIndex :uint) :Boolean
    {
        if (selectionIndex >= 0 && selectionIndex < SELECTIONS.length / 2) {
            var selectionLoc :Vector2 = (SELECTIONS[selectionIndex * 2] as Vector2);
            var delta :Vector2 = loc.clone();
            delta.subtract(selectionLoc);
            if (delta.lengthSquared <= (epsilon * epsilon)) {
                return true;
            }
        }

        return false;
    }

    public static function selectionIndexToString (index :int) :String
    {
        index *= 2;
        if (index >= 0 && index < SELECTIONS.length) {
            return SELECTIONS[index + 1] as String;
        }

        return "";
    }

    public static function stringToSelectionIndex (string :String) :int
    {
        for (var i :uint = 0; i < SELECTIONS.length / 2; ++i) {
            if ((SELECTIONS[(i * 2) + 1] as String) == string) {
                return i;
            }
        }

        return -1;
    }

    public static function getRandomSelectionString () :String
    {
        var index :int = Rand.nextIntRange(0, SELECTIONS.length / 2, Rand.STREAM_COSMETIC);
        return SELECTIONS[(index * 2) + 1];
    }

    protected var _sprite :Sprite = new Sprite();

    protected static const SELECTIONS :Array = [
        new Vector2(62, 108), "a",
        new Vector2(78, 96), "b",
        new Vector2(95, 93), "c",
        new Vector2(112, 85),  "d",
        new Vector2(126, 84), "e",
        new Vector2(142, 84), "f",
        new Vector2(157, 83), "g",
        new Vector2(170, 86), "h",
        new Vector2(183, 87), "i",
        new Vector2(194, 90), "j",
        new Vector2(204, 93), "k",
        new Vector2(217, 100), "l",
        new Vector2(230, 104), "m",
        new Vector2(67, 133), "n",
        new Vector2(81, 129), "o",
        new Vector2(94, 123), "p",
        new Vector2(106, 119), "q",
        new Vector2(119, 115), "r",
        new Vector2(135, 114), "s",
        new Vector2(148, 111), "t",
        new Vector2(159, 116), "u",
        new Vector2(173, 114), "v",
        new Vector2(186, 120), "w",
        new Vector2(201, 128), "x",
        new Vector2(216, 132), "y",
        new Vector2(224, 141), "z",

        new Vector2(78, 59),  "yes",
        new Vector2(219, 59), "no",
    ];

    /*
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
    */

}

}
