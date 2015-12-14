//
// $Id$
//
// Pixeltar - an avatar for Whirled

package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.events.Event;

import flash.geom.Rectangle;
import flash.geom.Point;

import flash.utils.ByteArray;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

[SWF(width="128", height="128")]
public class Pixeltar extends Sprite
{
    // Square dimensions of swf
    public static const SIZE :int = 128;

    public function Pixeltar ()
    {
        _ctrl = new AvatarControl(this);

        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleState);

        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        var ba :ByteArray = _ctrl.getDefaultDataPack();
        if (ba != null) {
            _pack = new DataPack(ba);
            _pack.getDisplayObjects({sheet: "Sheet"}, init);
        } else {
            trace("No datapack, 10 seconds to self destruct");
        }
    }

    protected function populate (map :Object, xml :XMLList, looping :Boolean) :Array
    {
        var buffer :Array = [];

        for each (var track :XML in xml) {
            var name :String = String(track.@name);
            map[name] = new Track(track.@frames.split(","), track.@delay.split(","), looping);
            buffer.push(name);
        }

        return buffer;
    }

    protected function init (images :Object) :void
    {
        var sheet :BitmapData = Bitmap(images.sheet as DisplayObject).bitmapData;

        var width :int = _pack.getNumber("Width");
        var height :int = _pack.getNumber("Height");

        // Dimensions of each sprite
        var w :int = sheet.width / width;
        var h :int = sheet.height / height;

        _scale = SIZE / Math.max(w, h);

        // Get the frame data
        _frames = [];
        for (var y :Number = 0; y < height; ++y) {
            for (var x :Number = 0; x < width; ++x) {
                var bmp :BitmapData = new BitmapData(w, h);
                bmp.copyPixels(sheet, new Rectangle(x*w, y*h, w, h), new Point(0, 0));
                //bmp.draw(sheet, null, null, null, new Rectangle(x*w, y*h, w, h));

                _frames.push(bmp);
            }
        }

        // Pull the walk speed from the remix
        _ctrl.setMoveSpeed(_pack.getNumber("Speed"));

        // Pull the (optional) hotspot from the remix
        var hotspot :Point = _pack.getPoint("Hotspot");
        if (hotspot != null) {
            _ctrl.setHotSpot(hotspot.x * _scale, hotspot.y * _scale);
        }

        _rightFacing = _pack.getBoolean("RightFacing");

        var tracks :XML = _pack.getFileAsXML("Tracks");

        _ctrl.registerActions(populate(_actions, tracks.action, false));
        _ctrl.registerStates(populate(_states, tracks.state, true));

        _surface = new Bitmap(_frames[0] as BitmapData);
        _surface.scaleX = _scale;
        _surface.scaleY = _scale;
        addChild(_surface);

        _onSpeak = _actions[_pack.getString("Speak")] as Track;
        if (_onSpeak != null) {
            _ctrl.addEventListener(ControlEvent.AVATAR_SPOKE, handleSpeak);
        }
        _onMove = _states[_pack.getString("Move")] as Track;
        if (_onMove != null) {
            _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleMovement);
            handleMovement();
        }
        _onIdle = _states[_pack.getString("Idle")] as Track;
        if (_onIdle != null) {
            _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleIdle);
            handleIdle();
        }

        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleOrientation);
        handleOrientation();

        playLow(_states[_ctrl.getState()]);
    }

    protected function handleFrameUpdate (event :AnimationEvent) :void
    {
        _flip = (event.frame < 0);
        _surface.bitmapData = _frames[Math.abs(event.frame)-1];

        handleOrientation();
    }

    protected function playHigh (track :Track) :void
    {
        if (_high != null) {
            _high.stop();
        }
        if (_low != null) {
            _low.stop();
        }

        _high = new Animation(track);
        _high.addEventListener(AnimationEvent.UPDATE, handleFrameUpdate);
        _high.addEventListener(AnimationEvent.COMPLETE, stopHigh);
        _high.start();
    }

    protected function stopHigh (... etc) :void
    {
        if (_high != null) {
            _high.stop();
        }

        _high = null;
        if (_low != null) {
            _low.start();
        }
    }

    protected function dontPlayHigh (track :Track) :void
    {
        if (_high != null && _high.track == track) {
            stopHigh();
        }
    }

    protected function playLow (track :Track) :void
    {
        if (_low != null) {
            _low.stop();
        }

        _low = new Animation(track);
        _low.addEventListener(AnimationEvent.UPDATE, handleFrameUpdate);

        if (_high == null) {
            _low.start();
        }
    }

    /** Only registered if we should handle isMoving() */
    protected function handleMovement (... etc) :void
    {
        (_ctrl.isMoving() ? playHigh : dontPlayHigh) (_onMove);
    }

    /** Only registered if we should handle isIdle() */
    protected function handleIdle (... etc) :void
    {
        (_ctrl.isSleeping() ? playHigh : dontPlayHigh) (_onIdle);
    }

    protected function handleOrientation (... etc) :void
    {
        var flop :Boolean = (_ctrl.getOrientation() > 180) == _rightFacing;

        // if (flip XOR flop)
        if ((_flip || flop) && !(_flip && flop)) {
            _surface.x = _surface.width;
            _surface.scaleX = -_scale;
        } else {
            _surface.x = 0;
            _surface.scaleX = _scale;
        }
    }

    /** Only registered if we should handle speaking. */
    protected function handleSpeak (event :Object = null) :void
    {
        playHigh(_onSpeak);
    }

    protected function handleAction (event :ControlEvent) :void
    {
        playHigh(_actions[event.name]);
    }

    protected function handleState (event :ControlEvent) :void
    {
        playLow(_states[event.name]);
    }

    protected function handleUnload (event :Event) :void
    {
        if (_low != null) {
            _low.stop();
        }
        if (_high != null) {
            _high.stop();
        }
    }

    // Maps strings to Tracks
    protected var _states :Object = {};
    protected var _actions :Object = {};

    // Special high Tracks for certain events
    protected var _onMove :Track;
    protected var _onIdle :Track;
    protected var _onSpeak :Track;

    /** A low priority channel for state animations. */
    protected var _low :Animation;

    /** A high priority channel for action/walking/idle animations. */
    protected var _high :Animation;

    protected var _surface :Bitmap;

    /** True if the current frame is inverted. */
    protected var _flip :Boolean;

    protected var _rightFacing :Boolean;
    protected var _scale :Number;

    /** Holds BitmapData for each frame. */
    protected var _frames :Array;

    protected var _pack :DataPack;

    protected var _ctrl :AvatarControl;
}
}
