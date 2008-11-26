//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import com.whirled.ToyControl;
import com.whirled.ControlEvent;

[SWF(width="318", height="300")]
public class Hospital extends Sprite
{
    public function Hospital ()
    {
        _ctrl = new ToyControl(this);

        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleMovement);

        _image = Bitmap(new IMAGE());
        addChild(_image);
    }

    public function handleMovement (event :ControlEvent) :void
    {
        if (event.value != null) {
            return; // Haven't arrived yet
        }

        var target :Object = QuestUtil.getService(_ctrl, event.name);
        if (target != null && target.getState() == QuestConstants.STATE_DEAD) {
            //if (QuestUtil.squareDistanceTo(_ctrl, event.name) < 200*200) {
                target.revive();
            //}
        }
    }

    protected var _ctrl :ToyControl;

    [Embed(source="icon.png")]
    protected static const IMAGE :Class;
    protected var _image :Bitmap;
}
}
