package {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;

import flash.filters.GlowFilter;

import com.threerings.flash.Siner;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="600", height="450")]
public class Fairy extends Sprite
{
    public function Fairy ()
    {
        _ctrl = new AvatarControl(this);
        _ctrl.setPreferredY(200); // pixels, love
        _platform = new Platform(_ctrl);

        _fairy = new Sprite();
        var g :Graphics = _fairy.graphics;
        g.beginFill(0xFFFFFF);
        g.drawCircle(0, 0, 3);
        g.endFill();
        _fairy.filters = [ new GlowFilter(0xFFFECC)];
        _platform.addChild(_fairy);
//
//        var other :Sprite = new Sprite();
//        g = other.graphics;
//        g.beginFill(0xFFFFFF);
//        g.drawRect(0, 0, 20, 20);
//        g.endFill();
//        g.beginFill(0x000000);
//        g.drawRect(20, 0, 20, 20);
//        g.endFill();
//        g.beginFill(0xFF0000);
//        g.drawRect(40, 0, 20, 10);
//        g.endFill();
//        g.beginFill(0x00FF00);
//        g.drawRect(40, 10, 20, 10);
//        g.endFill();
//        g.beginFill(0x0000FF);
//        g.drawRect(60, 0, 20, 20);
//        g.endFill();
//        other.y = 20;
//        //_platform.addChild(other);
//
//        other = new Sprite();
//        g = other.graphics;
//        g.beginFill(0x77FFFFFF);
//        g.drawCircle(0, 0, 20);
//        g.endFill();
//        g.beginFill(0xFFFFFF);
//        g.drawCircle(0, 0, 10);
//        g.endFill();
//        other.blendMode = BlendMode.INVERT;
//        _platform.addChildAt(other, 0);

        // first things first
        _platform.y = 40;
        _platform.x = 300;
        addChild(_platform);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);

        if (_ctrl.isConnected()) {
            _ctrl.registerStates(BlendMode.NORMAL, BlendMode.ADD, BlendMode.ALPHA, BlendMode.DARKEN,
                BlendMode.DIFFERENCE, BlendMode.ERASE, BlendMode.HARDLIGHT, BlendMode.INVERT,
                BlendMode.LAYER, BlendMode.LIGHTEN, BlendMode.MULTIPLY, BlendMode.OVERLAY,
                BlendMode.SCREEN, BlendMode.SUBTRACT);

            _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);
            handleStateChanged();
        }
    }

    protected function handleAdded (... ignored) :void
    {
        addEventListener(Event.ENTER_FRAME, handleFrame, false, int.MAX_VALUE);
        _x.reset();
        _y.reset();
        _height.reset();
    }

    protected function handleRemoved (... ignored) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected function handleStateChanged (... ignored) :void
    {
        this.blendMode = _ctrl.getState();
    }

    protected function handleFrame (... ignored) :void
    {
        _platform.setPosition(300 + _x.value, 40 + _y.value, _height.value);
    }

    protected var _fairy :Sprite;

    protected var _platform :Platform;

    protected var _ctrl :AvatarControl;

    protected var _x :Siner = new Siner(30, 1);
    protected var _y :Siner = new Siner(30, 1.05);

    protected var _height :Siner = new Siner(200, 5);
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

    public function setPosition (x :Number, y :Number, height :Number = NaN) :void
    {
        _x = x;
        _y = y;
        _height = height;
        super.x = x;
        super.y = y;
        updateHotSpot();
    }

    protected function updateHotSpot () :void
    {
        _ctrl.setHotSpot(_x, _y, _height);
    }

    /** Cache our latest actual x, y since reading them back out after setting them returns
     * the old value.. */
    protected var _x :Number = 0;
    protected var _y :Number = 0;
    protected var _height :Number = NaN;

    protected var _ctrl :AvatarControl;
}
