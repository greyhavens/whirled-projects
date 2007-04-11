package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;

import flash.filters.GlowFilter;

import com.threerings.flash.Siner;

import com.whirled.AvatarControl;

[SWF(width="600", height="450")]
public class Fairy extends Sprite
{
    public function Fairy ()
    {
        _ctrl = new AvatarControl(this);
        _platform = new Platform(_ctrl);

        _fairy = new Sprite();
        var g :Graphics = _fairy.graphics;
        g.beginFill(0xFFFFFF);
        g.drawCircle(0, 0, 3);
        g.endFill();
        _fairy.filters = [ new GlowFilter(0xFFFECC)];
        _platform.addChild(_fairy);

        // first things first
        _platform.y = 40;
        _platform.x = 300;
        addChild(_platform);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);
    }

    protected function handleAdded (... ignored) :void
    {
        addEventListener(Event.ENTER_FRAME, handleFrame, false, int.MAX_VALUE);
        _x.reset();
        _y.reset();
    }

    protected function handleRemoved (... ignored) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleFrame (... ignored) :void
    {
        _platform.y = 40 + _y.value;
        _platform.x = 300 + _x.value;
    }

    protected var _fairy :Sprite;

    protected var _platform :Platform;

    protected var _ctrl :AvatarControl;

    protected var _x :Siner = new Siner(30, 1);
    protected var _y :Siner = new Siner(30, 1.05);
}
}

import flash.display.Sprite;

import flash.geom.Point;

import com.whirled.AvatarControl;


/**
 * Simply position the platform to your desired hotspot, then position your content around
 * the platform's 0, 0 so that it's always relative to the hotspot.
 */
class Platform extends Sprite
{
    public function Platform (ctrl :AvatarControl)
    {
        _ctrl = ctrl;
        updateHotSpot();
    }

    override public function set x (newX :Number) :void
    {
        _x = newX;
        super.x = newX;
        updateHotSpot();
    }

    override public function set y (newY :Number) :void
    {
        _y = newY;
        super.y = newY;
        updateHotSpot();
    }

    protected function updateHotSpot () :void
    {
        _ctrl.setHotSpot(_x, _y);
    }

    /** Cache our latest actual x, y since reading them back out after setting them returns
     * the old value.. */
    protected var _x :Number = 0;
    protected var _y :Number = 0;

    protected var _ctrl :AvatarControl;
}
