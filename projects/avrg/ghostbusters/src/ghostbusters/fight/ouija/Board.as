package ghostbusters.fight.ouija {

import com.threerings.flash.Vector2;

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObject;
import flash.display.Sprite;

import ghostbusters.fight.common.*;

public class Board extends SceneObject
{
    public function Board ()
    {
        _sprite.addChild(SwfResource.getSwfDisplayRoot("ouija.board"));
        _sprite.mouseChildren = false;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get sprite () :Sprite
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
            var delta :Vector2 = loc.subtract(selectionLoc);
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
        new Vector2(65, 102), "a",
        new Vector2(77, 94), "b",
        new Vector2(91, 88), "c",
        new Vector2(107, 84),  "d",
        new Vector2(120, 80), "e",
        new Vector2(135, 80), "f",
        new Vector2(150, 79), "g",
        new Vector2(165, 80), "h",
        new Vector2(180, 80), "i",
        new Vector2(182, 83), "j",
        new Vector2(200, 85), "k",
        new Vector2(214, 91), "l",
        new Vector2(233, 100), "m",
        new Vector2(63, 135), "n",
        new Vector2(76, 126), "o",
        new Vector2(89, 121), "p",
        new Vector2(103, 116), "q",
        new Vector2(118, 112), "r",
        new Vector2(136, 110), "s",
        new Vector2(150, 109), "t",
        new Vector2(163, 108), "u",
        new Vector2(179, 110), "v",
        new Vector2(199, 114), "w",
        new Vector2(213, 125), "x",
        new Vector2(227, 129), "y",
        new Vector2(237, 139), "z",

        new Vector2(78, 58),  "yes",
        new Vector2(222, 59), "no",
    ];
}

}
