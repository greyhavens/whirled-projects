package ghostbusters.fight.ouija {

import flash.display.DisplayObject;
import flash.display.Sprite;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.util.Rand;

public class Board extends SceneObject
{
    public function Board ()
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

    public static function getSelectionStringAt (loc :Vector2, epsilon :int) :String
    {
        return Board.selectionIndexToString(Board.getSelectionIndexAt(loc, epsilon));
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
        new Vector2(64, 110), "a",
        new Vector2(79, 97), "b",
        new Vector2(97, 92), "c",
        new Vector2(112, 88),  "d",
        new Vector2(127, 86), "e",
        new Vector2(144, 85), "f",
        new Vector2(160, 85), "g",
        new Vector2(172, 87), "h",
        new Vector2(185, 88), "i",
        new Vector2(195, 91), "j",
        new Vector2(208, 96), "k",
        new Vector2(219, 102), "l",
        new Vector2(233, 106), "m",
        new Vector2(68, 134), "n",
        new Vector2(82, 132), "o",
        new Vector2(96, 126), "p",
        new Vector2(108, 121), "q",
        new Vector2(123, 118), "r",
        new Vector2(137, 117), "s",
        new Vector2(151, 113), "t",
        new Vector2(161, 118), "u",
        new Vector2(175, 116), "v",
        new Vector2(190, 122), "w",
        new Vector2(203, 130), "x",
        new Vector2(218, 133), "y",
        new Vector2(228, 143), "z",

        new Vector2(80, 60),  "yes",
        new Vector2(222, 60), "no",
    ];
}

}
