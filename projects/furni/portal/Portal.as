package {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;

import flash.utils.getTimer; // function import

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

[SWF(width="300", height="450")]
public class Portal extends Sprite
{
    public function Portal ()
    {
        _ctrl = new FurniControl(this);
        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);


        var base :Sprite = new Sprite();
        var g :Graphics = base.graphics;
        g.beginFill(0x33CC99);
        g.lineStyle(2, 0x333333);
        g.drawEllipse(-16, -8, 32, 16);
        g.endFill();

        base.x = 150;
        base.y = 434;
        addChild(base);
        _ctrl.setHotSpot(150, 434);

        _ray = new Sprite();
        _ray.blendMode = BlendMode.INVERT;
        _ray.x = 150;
        _ray.y = 434;
        addChild(_ray);
    }

    protected function handleAction (event :ControlEvent) :void
    {
        switch (event.name) {
        case "bodyEntered":
            triggerAnim(true);
            break;

        case "bodyLeft":
            triggerAnim(false);
            break;

        default:
            trace("Received unknown action: " + event);
            break;
        }
    }

    protected function handleUnload (... ignored) :void
    {
        // in case we're currently animating...
        removeEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function triggerAnim (entering :Boolean) :void
    {
        // if we're still animating something else...
        if (_mode != null) {
            return;
        }

        _mode = entering;
        _stamp = getTimer();
        addEventListener(Event.ENTER_FRAME, handleFrame);
        handleFrame();
    }

    protected function handleFrame (... ignored) :void
    {
        var g :Graphics = _ray.graphics;
        g.clear();

        var elapsed :Number = getTimer() - _stamp;
        if (elapsed >= 1000) {
            _mode = null;
            removeEventListener(Event.ENTER_FRAME, handleFrame);
            return;
        }

        if (_mode === true) { // if entering, reverse it
            elapsed = 1000 - elapsed;
        }

        var radius :Number = (elapsed >= 500) ? 6 + (40 * ((elapsed - 500) / 500)) : 6;
        var height :Number = (Math.min(elapsed, 500) / 500) * 391;

        // first, draw the circle at the height
        if (radius > 0) {
            g.beginFill(0xFFFFFF);
            g.drawCircle(0, -height, radius);
            g.endFill();
        }

        // fill in
        if (height > 0) {
            g.beginFill(0xFFFFFF);
            g.moveTo(0, 0);
            g.lineTo(-radius, -height);
            g.lineTo(radius, -height);
            g.lineTo(0, 0);
            g.endFill();
        }
    }

    protected var _ctrl :FurniControl;

    protected var _ray :Sprite;

    protected var _mode :Object;

    protected var _stamp :Number;
}
}
