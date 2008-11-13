//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import com.whirled.ToyControl;
import com.whirled.ControlEvent;

[SWF(width="186", height="124")]
public class Totem extends Sprite
{
    public function Totem ()
    {
        _ctrl = new ToyControl(this);
        _ctrl.registerPropertyProvider(propertyProvider);

        _image = Bitmap(new IMAGE());
        addChild(_image);
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
