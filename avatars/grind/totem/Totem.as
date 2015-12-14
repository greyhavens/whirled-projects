//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import flash.text.TextFieldAutoSize;

import com.threerings.flash.TextFieldUtil;

import com.whirled.ToyControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

[SWF(width="186", height="124")]
public class Totem extends Sprite
{
    public function Totem ()
    {
        _ctrl = new ToyControl(this);
        _ctrl.registerPropertyProvider(propertyProvider);

        _image = Bitmap(new IMAGE());
        addChild(_image);

        DataPack.load(_ctrl.getDefaultDataPack(), handlePack);
    }

    public function handlePack (pack :DataPack) :void
    {
        _influence = pack.getNumber("Influence");

        addChild(TextFieldUtil.createField(""+_influence, {
                autoSize: TextFieldAutoSize.LEFT,
                outlineColor: 0xFFFFFF
            }, {
                bold: true,
                color: 0xFF0000,
                font: "sans",
                size: 36
            }));

    }

    public function propertyProvider (key :String) :Object
    {
        if (key == QuestConstants.TOTEM_KEY) {
            return _influence;
        } else {
            return null;
        }
    }

    protected var _ctrl :ToyControl;
    protected var _influence :int = 10; // TODO: Remixable

    [Embed(source="icon.png")]
    protected static const IMAGE :Class;
    protected var _image :Bitmap;
}
}
