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
import flash.utils.getTimer; // function import

import com.threerings.flash.FrameSprite;
import com.threerings.flash.Siner;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

// TODO
// - allow a point to be selected as a temporary mouthspot, to "throw" your voice onto
//   another avatar
[SWF(width="600", height="450")]
public class Fairy extends FrameSprite
{
    /** States. */
    public static const DEFAULT_STATE :String = "Default";
    public static const SWIRL_STATE :String = "Swirl";
    public static const MOTION_STATE :String = "Mouse Sparkle";

    public static const SEND_INTERVAL :int = 400; // 400 ms

//    /** Actions. */
//    public static const SKYWRITE_ACTION :String = "Skywrite";
//
//    /** Messages. */
//    public static const SKYWRITE_MSG :String = "Skywrite";

    public function Fairy ()
    {
        super(true);

        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.setPreferredY(200); // pixels, love
        _platform = new Platform(_ctrl);

        _fairy = new Sprite();
        var g :Graphics = _fairy.graphics;
        g.beginFill(0xFFFFFF);
        //g.beginFill(0xFF0000);
        g.drawCircle(0, 0, 5);
        g.endFill();
        _fairy.filters = [ new GlowFilter(0xFFFECC)];
        _platform.addChild(_fairy);

        // first things first
        _platform.setPosition(300, 225, 50);
        addChild(_platform);

        if (_ctrl.isConnected()) {
            _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleStateChanged);
            _ctrl.addEventListener(ControlEvent.MESSAGE_RECEIVED, handleMessageReceived);

            _ctrl.registerStates(DEFAULT_STATE, SWIRL_STATE, MOTION_STATE);
        }

        // always check our current state
        handleStateChanged();
    }

    protected function handleUnload (... ignored) :void
    {
        // nothing right now
    }

    override protected function handleFrame (... ignored) :void
    {
        var now :Number = getTimer();

        if ((_state == MOTION_STATE) && _ctrl.hasControl()) {
            _sendingData.push(now, mouseX - 300, mouseY - 225);

            if (now >= _nextSend) {
                _ctrl.sendMessage(MOTION_MSG, _sendingData);
                _sendingData = [];
                _nextSend = now + SEND_INTERVAL;
            }
        }

        // if there's motion data to play out... (Even if we're no longer in that state...)
        if (_motionData.length > 0) {
            if (_motionStart) {
                _motionStart = false;
                // on the first time, calculate our difference
                var startStamp :Number = _motionData[0] as Number;
                // the difference between now and stamp is our offset
                _motionOffset = startStamp - now - SEND_INTERVAL;
            }

            var stamp :Number = now + _motionOffset;
            while (_motionData.length > 0 && Number(_motionData[0]) < stamp) {
                var data :Array = _motionData.splice(0, 3);
                // drop a sparkle at the location
                moveAndSparkle(Number(data[1]), Number(data[2]));
            }
        }

        if (_state == SWIRL_STATE) {
            var extent :Number = Math.abs(_center.value);
            moveAndSparkle(_swirlX.value * extent, _swirlY.value * extent);
        }
    }

    protected function moveAndSparkle (xx :Number, yy :Number) :void
    {
        _fairy.x = xx;
        _fairy.y = yy;
        _platform.addChildAt(new Sparkle(xx, yy), 0);
    }

    protected function handleMessageReceived (event :ControlEvent) :void
    {
        switch (event.name) {
        case MOTION_MSG:
            _motionData.push.apply(null, event.value);
            break;

//        case SKYWRITE_MSG:
//            doSkywrite(event.value as String);
//            break;
        }
    }

    protected function handleStateChanged (... ignored) :void
    {
        _state = _ctrl.getState();

        switch (_state) {
        case SWIRL_STATE:
            _swirlX.reset();
            _swirlY.reset();
            break;

        case MOTION_STATE:
            _motionStart = true;
            _motionData = [];
            if (_ctrl.hasControl()) {
                _sendingData = [];
                _nextSend = getTimer() + SEND_INTERVAL;
            }
            break;
        }
    }

//    protected function handleActionTriggered (event :ControlEvent) :void
//    {
//        switch (event.name) {
//        case SKYWRITE_ACTION:
//            if (_ctrl.hasControl()) {
//                showInputField();
//            }
//        }
//    }
//
//    protected function showInputField (... ignored) :void
//    {
//        if (_input == null) {
//            _input = new TextField();
//            _input.background = true;
//            _input.width = 600;
//            _input.height = 20;
//            _input.type = TextFieldType.INPUT;
//            _input.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
//            addChild(_input);
//        }
//
//        this.stage.focus = _input;
//    }
//
//    protected function handleKeyDown (event :KeyboardEvent) :void
//    {
//        if (event.keyCode != Keyboard.ENTER) {
//            return;
//        }
//
//        var txt :String = _input.text;
//        if (txt != "") {
//            _ctrl.sendMessage(SKYWRITE_MSG, txt);
//            _input.text = "";
//            this.stage.focus = _input;
//
//        } else {
//            removeChild(_input);
//            _input = null;
//        }
//    }
//
//    protected function doSkywrite (msg :String) :void
//    {
//        trace("Doing skywrite: " + msg);
//
//        _formatter = new TextField();
//        _formatter.width = 600;
//        _formatter.height = 450;
//        _formatter.autoSize = TextFieldAutoSize.CENTER;
//        _formatter.multiline = true;
//
//        var fmt :TextFormat = new TextFormat();
//        fmt.align = TextFormatAlign.CENTER;
//        fmt.font = "Arial";
//        var size :int = 48;
//        fmt.size = size;
//        _formatter.defaultTextFormat = fmt;
//        _formatter.text = msg;
//
//        var lastHeight :Number;
//        do {
//            lastHeight = _formatter.textHeight;
//            size += 12;
//            fmt.size = size;
//            _formatter.defaultTextFormat = fmt;
//            _formatter.text = msg;
//            if (_formatter.textWidth > 600) {
//                break;
//            }
//            //trace("Trying " + size + ", " + _formatter.textWidth + ", " + _formatter.textHeight);
//        } while (_formatter.textHeight < 450 && _formatter.textHeight != lastHeight);
//
//        // then, back up one
//        size -= 12;
//        fmt.size = size;
//        _formatter.defaultTextFormat = fmt;
//        _formatter.text = msg;
//
//        addChild(_formatter);
//        trace("Added with " + _formatter.textWidth + ", " + _formatter.textHeight);
//
//        _skyMsgs.push(msg);
//    }

    protected var _fairy :Sprite;

    protected var _platform :Platform;

    protected var _ctrl :AvatarControl;

    /** Are we on the stage? Used because stage is still non-null while handling
     * REMOVED_FROM_STAGE. */
    protected var _onStage :Boolean;

    /** Our state, cached. */
    protected var _state :String;

    protected var _nextSend :Number;

    protected var _sendingData :Array = [];

    /** Set to true when we first transition to the mouse motion state. */
    protected var _motionStart :Boolean = false;

    protected var _motionData :Array = [];

    protected var _motionOffset :Number;

//    protected var _input :TextField;
//
//    protected var _skyMsgs :Array = [];
//
//    protected var _formatter :TextField;
//

    protected var _swirlX :Siner = new Siner(275, 4);

    protected var _swirlY :Siner = new Siner(200, 3.9);

    protected var _center :Siner = new Siner(.5, 10, .5, 5);

    protected static const MOTION_MSG :String = "mot";
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
