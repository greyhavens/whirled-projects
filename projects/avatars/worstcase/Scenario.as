//
// 


package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.external.ExternalInterface;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.utils.Timer;

import com.threerings.util.Util;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;


import mx.core.MovieClipLoaderAsset;


[SWF(width="50", height="450")]
public class Scenario extends Sprite
{
    public static const ACT_EXTERNAL :String = "Test ExternalInterface";
    public static const ACT_PROBE :String = "Probe Hierarchy";
    public static const ACT_CRASH :String = "Crash loop once";

    public static const STATE_NORMAL :String = "Chill";
    public static const STATE_CRASH :String = "Crash loop forever";

    public function Scenario ()
    {
        graphics.beginFill(0x4aa774);
        graphics.drawRect(0, 0, 50, 450);
        graphics.endFill();
        graphics.lineStyle(1, 0xFF0000);
        graphics.moveTo(0, 0);
        graphics.lineTo(50, 0);
        graphics.moveTo(0, 449);
        graphics.lineTo(50, 449);

        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);
        _ctrl.addEventListener(ControlEvent.AVATAR_SPOKE, handleAvatarSpoke);
        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleActionTriggered);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);

        _ctrl.doBatch(function () :void {
            _ctrl.registerStates(STATE_NORMAL, STATE_CRASH);
            _ctrl.registerActions(ACT_EXTERNAL, ACT_PROBE, ACT_CRASH);
        });
    }

    protected function handleActionTriggered (event :ControlEvent) :void
    {
        switch (event.name) {
        case ACT_EXTERNAL:
            ExternalInterface.call("clearClient");
            break;

        case ACT_CRASH:
            crashWhileLoop("Haw haw. I crawsh you.");
            break;

        case ACT_PROBE:
            probeHierarchy();
            break;
        }
    }

    protected function handleStateChanged (event :ControlEvent) :void
    {
        if (event.name == STATE_CRASH) {
            // infinite loopin' timer
            _timer = new Timer(800);
            _timer.addEventListener(TimerEvent.TIMER, handleTimer);
            _timer.start();
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

    protected function handleUnload (event :Event) :void
    {
        if (_timer != null) {
            _timer.stop();
        }
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

    protected function probeHierarchy () :void
    {
        trace("=== Probing hierarchy...");
        var d :DisplayObject = this;
        try {
            while (d != null) {
                trace(":: " + d);
                d = d.parent;
            }
            trace("=== Probe succeeded.");

        } catch (err :SecurityError) {
            trace("=== Probe failed: " + err);
        }
    }

    protected var _ctrl :AvatarControl;

    protected var _timer :Timer;
}
}
