//
// 


package {


import flash.display.Sprite;

import flash.events.TimerEvent;

import flash.utils.Timer;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;


[SWF(width="50", height="300")]
public class Scenario extends Sprite
{
    public function Scenario ()
    {
        graphics.beginFill(0x4aa774);
        graphics.drawRect(0, 0, 50, 300);
        graphics.endFill();

        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);
        _ctrl.addEventListener(ControlEvent.AVATAR_SPOKE, handleAvatarSpoke);
        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleActionTriggered);

        _ctrl.registerStates("Chill", "Crash");
        _ctrl.registerActions("Crash");
    }

    protected function handleActionTriggered (event :ControlEvent) :void
    {
        if (event.name == "Crash") {
            // infinite loopin' timer
            _timer = new Timer(800);
            _timer.addEventListener(TimerEvent.TIMER, handleTimer);
            _timer.start();
        }
    }

    protected function handleStateChanged (event :ControlEvent) :void
    {
        if (event.name == "Crash") {
            crashWhileLoop("Haw haw. I crawsh you.");
        }
    }

    protected function handleAvatarSpoke (event :ControlEvent) :void
    {
        var t :String = null;
        trace("blipple: " + t.substring(1));
    }

    protected function handleTimer (event :TimerEvent) :void
    {
        crashWhileLoop("think of what?");
    }

    protected function crashWhileLoop (message :String = null) :void
    {
        if (message != null) {
            trace(message);
        }
        while (true) {
            // it's not a tumor!
        }
    }

    protected var _ctrl :AvatarControl;

    protected var _timer :Timer;

}
}
