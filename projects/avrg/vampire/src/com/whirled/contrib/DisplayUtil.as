package com.whirled.contrib
{
import com.threerings.flash.TextFieldUtil;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.text.TextField;

public class DisplayUtil
{
    public static function detach (d :DisplayObject) :void
    {
        if (d != null && d.parent != null) {
            d.parent.removeChild(d);
        }
    }

    public static function drawText (parent :DisplayObjectContainer, text :String, x :int,
        y :int) :void
    {
        var tf :TextField = TextFieldUtil.createField(text, {x:x, y:y, selectable:false});
        parent.addChild(tf);
    }

}
}