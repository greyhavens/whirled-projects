package com.whirled.contrib
{
import com.threerings.flash.TextFieldUtil;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

public class DisplayUtil
{
    public static function detach (d :DisplayObject) :void
    {
        if (d != null && d.parent != null) {
            d.parent.removeChild(d);
        }
    }

    public static function removeAllChildren (parent :DisplayObjectContainer) :void
    {
        while (parent.numChildren > 0) {
            parent.removeChildAt(0);
        }
    }

    public static function drawText (parent :DisplayObjectContainer, text :String, x :int = 0,
        y :int = 0) :void
    {
        var tf :TextField = TextFieldUtil.createField(text, {x:x, y:y, selectable:false});
        parent.addChild(tf);
        tf.width = 100;
    }

    public static function placeSequence (parent :DisplayObjectContainer, seq :Array, startX :int,
        startY :int, leftToRight :Boolean = true, gap :int = 5) :void
    {
        if (seq == null || seq.length == 0 || parent == null) {
            return;
        }

        for each (var d :DisplayObject in seq) {
            if (d == null) {
                continue;
            }
            parent.addChild(d);
            var adjust :int = leftToRight ? d.width / 2 : -d.width / 2;
            centerOn(d, startX + adjust, startY);
            startX += leftToRight ? d.width + gap : -(d.width + gap);
        }
    }

    public static function distribute (seq :Array, startX :int,
        startY :int, endX :int, endY :int) :void
    {
        if (seq == null || seq.length == 0) {
            return;
        }

        var xInc :int = (endX - startX) / (seq.length + 1);
        startX += xInc / 2;
        var yInc :int = (endY - startY) / (seq.length + 1);
        startY += yInc / 2;

        for (var ii :int = 0; ii < seq.length; ++ii) {
            centerOn(seq[ii], startX + ii * xInc, startY + ii * yInc);
        }
    }

    public static function distributionPoint (index :int, length :int, startX :int,
        startY :int, endX :int, endY :int) :Point
    {
        var xInc :int = (endX - startX) / (length + 1);
        startX += xInc;
        var yInc :int = (endY - startY) / (length + 1);
        startY += yInc;
        return new Point(startX + index * xInc, startY + index * yInc);
    }

    public static function centerOn (d :DisplayObject, x :int, y :int) :void
    {
        d.x = x;
        d.y = y;
        var bounds :Rectangle = d.getBounds(d);
        d.x -= (bounds.width / 2) + bounds.left;
        d.y -= (bounds.height / 2) + bounds.top;
    }

}
}