//
// $Id$

package {

import flash.display.Sprite;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="50", height="200")]
public class Test extends Sprite
{
    public function Test ()
    {
        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, 50, 200);
        graphics.endFill();

        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(ControlEvent.CONTROL_ACQUIRED, setupCtrl);

        if (_ctrl.hasControl()) {
            trace("MemTestAvatar: already has control. Yay!");
            setupCtrl();
        }
    }

    protected function setupCtrl (... ignored) :void
    {
        _ctrl.addEventListener(ControlEvent.AVATAR_SPOKE, handleSpoke);
        _count = int(_ctrl.getMemory("spoke"));
        trace("MemTestAvatar: initial spoke count: " + _count);
    }

    protected function handleSpoke (... ignored) :void
    {
        _count++;
        _ctrl.setMemory("spoke", _count);
        trace("MemTestAvatar: set spoke count to: " + _count);
    }


    protected var _ctrl :AvatarControl;

    protected var _count :int;
}
}
