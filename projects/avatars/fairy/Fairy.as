package {

import flash.display.BlendMode;
import flash.display.Loader;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.net.URLLoader;
import flash.net.URLRequest;

import flash.filters.GlowFilter;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import flash.ui.Keyboard;

import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.getTimer;

import com.threerings.flash.Siner;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="600", height="450")]
public class Fairy extends Sprite
{
    /** States. */
    public static const DEFAULT_STATE :String = "Default";
    public static const SWIRL_STATE :String = "Swirl";
    public static const MOTION_STATE :String = "Mouse Motion"; // DOES NOT WORK

    /** Actions. */
    public static const SKYWRITE_ACTION :String = "Skywrite";

    /** Messages. */
    public static const SKYWRITE_MSG :String = "Skywrite";

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
        _platform.setPosition(300, 225, 50);
        addChild(_platform);

        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);

        if (_ctrl.isConnected()) {
            _ctrl.addEventListener(ControlEvent.GOT_CONTROL, handleGotControl);
            _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);
            _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleActionTriggered);
            _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessageReceived);

            if (_ctrl.hasControl()) {
                handleGotControl();

            } else {
                _ctrl.requestControl();
            }

            _ctrl.registerStates(DEFAULT_STATE, SWIRL_STATE /*, MOTION_STATE*/);
            _ctrl.registerActions(SKYWRITE_ACTION);
        }

        // always check our current state
        handleStateChanged();
    }

    protected function handleAdded (... ignored) :void
    {
        _onStage = true;
        // check our state
        handleStateChanged();
        recheckEnterFrame();
    }

    protected function handleRemoved (... ignored) :void
    {
        _onStage = false;
        shutdownMotionTimer();
        recheckEnterFrame();
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

        case SKYWRITE_MSG:
            doSkywrite(event.value as String);
            break;
        }
    }

    protected function handleStateChanged (... ignored) :void
    {
        _state = _ctrl.getState();

        switch (_state) {
        default:
            removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMotion);
            shutdownMotionTimer();
            // send one last update?
            handleMotionTimer();
            break;

        case SWIRL_STATE:
            _swirlX.reset();
            _swirlY.reset();
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

        recheckEnterFrame();
    }

    protected function recheckEnterFrame () :void
    {
        if (_onStage && (_state == SWIRL_STATE)) {
            addEventListener(Event.ENTER_FRAME, handleFrame);
        } else {
            removeEventListener(Event.ENTER_FRAME, handleFrame);
        }
    }

    protected function handleActionTriggered (event :ControlEvent) :void
    {
        switch (event.name) {
        case SKYWRITE_ACTION:
            if (_ctrl.hasControl()) {
                showInputField();
            }
        }
    }

    protected function handleFrame (... ignored) :void
    {
        if (_state == SWIRL_STATE) {
            var extent :Number = Math.abs(_center.value);
            _fairy.x = _swirlX.value * extent;
            _fairy.y = _swirlY.value * extent;
            _platform.addChild(new Sparkle(_fairy.x, _fairy.y));
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

    protected function showInputField (... ignored) :void
    {
        if (_input == null) {
            _input = new TextField();
            _input.background = true;
            _input.width = 600;
            _input.height = 20;
            _input.type = TextFieldType.INPUT;
            _input.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
            addChild(_input);
        }

        this.stage.focus = _input;
    }

    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        if (event.keyCode != Keyboard.ENTER) {
            return;
        }

        var txt :String = _input.text;
        if (txt != "") {
            _ctrl.sendMessage(SKYWRITE_MSG, txt);
            _input.text = "";
            this.stage.focus = _input;

        } else {
            removeChild(_input);
            _input = null;
        }
    }

    protected function doSkywrite (msg :String) :void
    {
        trace("Doing skywrite: " + msg);

        _formatter = new TextField();
        _formatter.width = 600;
        _formatter.height = 450;
        _formatter.autoSize = TextFieldAutoSize.CENTER;
        _formatter.multiline = true;

        var fmt :TextFormat = new TextFormat();
        fmt.align = TextFormatAlign.CENTER;
        fmt.font = "Arial";
        var size :int = 48;
        fmt.size = size;
        _formatter.defaultTextFormat = fmt;
        _formatter.text = msg;

        var lastHeight :Number;
        do {
            lastHeight = _formatter.textHeight;
            size += 12;
            fmt.size = size;
            _formatter.defaultTextFormat = fmt;
            _formatter.text = msg;
            if (_formatter.textWidth > 600) {
                break;
            }
            //trace("Trying " + size + ", " + _formatter.textWidth + ", " + _formatter.textHeight);
        } while (_formatter.textHeight < 450 && _formatter.textHeight != lastHeight);

        // then, back up one
        size -= 12;
        fmt.size = size;
        _formatter.defaultTextFormat = fmt;
        _formatter.text = msg;

        addChild(_formatter);
        trace("Added with " + _formatter.textWidth + ", " + _formatter.textHeight);

        _skyMsgs.push(msg);
    }

    protected var _fairy :Sprite;

    protected var _platform :Platform;

    protected var _ctrl :AvatarControl;

    /** Are we on the stage? Used because stage is still non-null while handling
     * REMOVED_FROM_STAGE. */
    protected var _onStage :Boolean;

    /** Our state, cached. */
    protected var _state :String;

    protected var _motionPoint :Point;

    protected var _motionTimer :Timer;

    protected var _input :TextField;

    protected var _skyMsgs :Array = [];

    protected var _formatter :TextField;


    protected var _swirlX :Siner = new Siner(275, 4);

    protected var _swirlY :Siner = new Siner(200, 3.9);

    protected var _center :Siner = new Siner(.5, 10, .5, 5);
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
