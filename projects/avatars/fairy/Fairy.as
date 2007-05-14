package {

import flash.display.BlendMode;
import flash.display.Loader;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.net.URLLoader;
import flash.net.URLRequest;

import flash.filters.GlowFilter;

import flash.text.TextField;

import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.threerings.flash.Siner;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="600", height="450")]
public class Fairy extends Sprite
{
    public static const DEFAULT_STATE :String = "Default";
    public static const MOTION_STATE :String = "Mouse Motion";

    // TODO
    // "Skywriting"
    // Show a text field, allow text entry
    // snapshot entered text into a TextField, print it to a ByteArray, and then
    // have the fairy trace out the tunred-on pixels and leave sparkles.
    // 
    public function Fairy ()
    {
        _ctrl = new AvatarControl(this);
        _ctrl.setPreferredY(200); // pixels, love
        _platform = new Platform(_ctrl);

        _fairy = new Sprite();
        var g :Graphics = _fairy.graphics;
        g.beginFill(0xFFFFFF);
        g.drawCircle(0, 0, 5);
        g.endFill();
        _fairy.filters = [ new GlowFilter(0xFFFECC)];
        _platform.addChild(_fairy);

        // first things first
        _platform.y = 40;
        _platform.x = 300;
        addChild(_platform);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);

        if (_ctrl.isConnected()) {
            _ctrl.addEventListener(ControlEvent.GOT_CONTROL, handleGotControl);
            _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);
            _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessageReceived);

            if (_ctrl.hasControl()) {
                handleGotControl();

            } else {
                _ctrl.requestControl();
            }

            _ctrl.registerStates(DEFAULT_STATE, MOTION_STATE);
        }
    }

    protected function handleAdded (... ignored) :void
    {
        // check our state
        handleStateChanged();
    }

    protected function handleRemoved (... ignored) :void
    {
        shutdownMotionTimer();
    }

    protected function handleGotControl (... ignored) :void
    {
        handleStateChanged();
    }

    protected function handleMessageReceived (event :ControlEvent) :void
    {
        switch (event.name) {
        case MOTION_STATE:
            var p :Point = event.value as Point;
            _fairy.x = p.x;
            _fairy.y = p.y;
            break;
        }
    }

    protected function handleStateChanged (... ignored) :void
    {
        var state :String = _ctrl.getState();

        switch (state) {
        default:
            removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMotion);
            shutdownMotionTimer();
            // send one last update?
            handleMotionTimer();
            break;

        case MOTION_STATE:
            trace("Switching to motion...");
            if (_ctrl.hasControl()) {
                trace("HAS got control!");
                addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMotion);
                if (_motionTimer == null) {
                    _motionTimer = new Timer(100);
                    _motionTimer.addEventListener(TimerEvent.TIMER, handleMotionTimer);
                    _motionTimer.start();
                }
            }
            break;
        }
    }

    protected function shutdownMotionTimer () :void
    {
        if (_motionTimer != null) {
            _motionTimer.stop();
            _motionTimer = null;
        }
    }

    protected function handleMouseMotion (event :MouseEvent) :void
    {
        trace("Got motion point..");
        _motionPoint = new Point(event.localX, event.localY);
    }

    protected function handleMotionTimer (... ignored) :void
    {
        if (_motionPoint != null) {
            _ctrl.sendMessage(MOTION_STATE, _motionPoint);
            _motionPoint = null;
        }
    }

//    protected function handleFrame (... ignored) :void
//    {
//        _platform.setPosition(300 + _x.value, 40 + _y.value, _height.value);
//    }

    protected var _fairy :Sprite;

    protected var _platform :Platform;

    protected var _ctrl :AvatarControl;

    protected var _motionPoint :Point;

    protected var _motionTimer :Timer;
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
