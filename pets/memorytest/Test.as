//
// $Id$

package {

import flash.display.Sprite;

import com.whirled.PetControl;
import com.whirled.ControlEvent;

[SWF(width="50", height="200")]
public class Test extends Sprite
{
    public function Test ()
    {
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, 50, 200);
        graphics.endFill();

        _ctrl = new PetControl(this);
        _ctrl.addEventListener(ControlEvent.CONTROL_ACQUIRED, setupCtrl);
        if (_ctrl.hasControl()) {
            trace("MemTestPet: already has control. Yay!");
            setupCtrl();
        }
    }

    protected function setupCtrl (... ignored) :void
    {
        _ctrl.addEventListener(ControlEvent.CHAT_RECEIVED, handleChat);
        _count = int(_ctrl.getMemory("heard"));
        trace("MemTestPet: initial heard count: " + _count);
    }

    protected function handleChat (... ignored) :void
    {
        _count++;
        _ctrl.setMemory("heard", _count);
        trace("MemTestPet: set heard count to: " + _count);
    }

    protected var _ctrl :PetControl;

    protected var _count :int;
}
}
