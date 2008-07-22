//
// $Id$
//
// Pixeltar - an avatar for Whirled

package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import flash.geom.Rectangle;
import flash.geom.Point;

import flash.utils.ByteArray;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

[SWF(width="50", height="50")]
public class Pixeltar extends Sprite
{
    public function Pixeltar ()
    {
        _ctrl = new AvatarControl(this);

        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, handleState);

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
            var anim :Animation = new Animation(track.@frames.split(","), track.@delay.split(","), looping);
            anim.addEventListener(AnimationEvent.UPDATE, handleFrameUpdate);
            anim.addEventListener(AnimationEvent.COMPLETE, function (... etc) {
                pushAnimation(_states[_ctrl.getState()]);
            });

            map[name] = anim;
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

        // Get the frame data
        _frames = [];
        for (var y :Number = 0; y < height; ++y) {
            for (var x :Number = 0; x < width; ++x) {
                var bmp :BitmapData = new BitmapData(w, h);
                bmp.copyPixels(sheet, new Rectangle(x*w, y*h, w, h), new Point(0, 0));

                _frames.push(bmp);
            }
        }

        // Pull the walk speed from the remix
        _ctrl.setMoveSpeed(_pack.getNumber("Speed"));

        var tracks :XML = _pack.getFileAsXML("Tracks");

        _ctrl.registerActions(populate(_actions, tracks.action, false));
        _ctrl.registerStates(populate(_states, tracks.state, true));

        _current = new Bitmap(_frames[0] as BitmapData);
        addChild(_current);

        if (_pack.getString("Speak") in _actions) {
            _ctrl.addEventListener(ControlEvent.AVATAR_SPOKE, handleSpeak);
        }
        if (_pack.getString("Move") in _states) {
            _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleMovement);
            handleMovement();
        }
        if (_pack.getString("Idle") in _states) {
            _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleIdle);
            handleIdle();
        }

        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, handleOrientation);
        handleOrientation();

        pushAnimation(_states[_ctrl.getState()]);
    }

    protected function handleFrameUpdate (event :AnimationEvent) :void
    {
        _current.bitmapData = _frames[event.frame];
    }

    // TODO: Real animation management
    var tmp :Animation;
    protected function pushAnimation (anim :Animation)
    {
        if (tmp != null) {
            tmp.stop();
        }

        tmp = anim;
        anim.play();
    }

    /** Only registered if we should handle isMoving() */
    protected function handleMovement (... etc) :void
    {
        if (_ctrl.isMoving()) {
            pushAnimation(_states[_pack.getString("Move")]);
        } else {
            pushAnimation(_states[_ctrl.getState()]);
        }
    }

    /** Only registered if we should handle isIdle() */
    protected function handleIdle (... etc) :void
    {
        if (_ctrl.isSleeping()) {
            pushAnimation(_states[_pack.getString("Idle")]);
        } else {
            if ( ! _ctrl.isMoving()) {
                pushAnimation(_states[_ctrl.getState()]);
            }
        }
    }

    protected function handleOrientation (... etc) :void
    {
        if ((_ctrl.getOrientation() > 180) == _pack.getBoolean("RightFacing")) {
            _current.x = _current.width;
            _current.scaleX = -1;
        } else {
            _current.x = 0;
            _current.scaleX = 1;
        }
        // Draw your avatar here using the appropriate orientation and accounting for whether it is
        // walking
    }

    /** Only registered if we should handle speaking. */
    protected function handleSpeak (event :Object = null) :void
    {
        pushAnimation(_actions[_pack.getString("Speak")]);
    }

    protected function handleAction (event :ControlEvent) :void
    {
        pushAnimation(_actions[event.name]);
    }

    protected function handleState (event :ControlEvent) :void
    {
        pushAnimation(_states[event.name]);
    }

    protected var _states :Object = {};
    protected var _actions :Object = {};

    protected var _current :Bitmap;
    protected var _frames :Array;
    protected var _pack :DataPack;

    protected var _ctrl :AvatarControl;
}
}
