//
// $Id: EasyImagePet.as 4584 2008-06-02 23:19:50Z ray $

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.utils.getTimer; // function import
import flash.events.TimerEvent;

import com.whirled.PetControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;

/**
 * EasyImagePet. An extremely simple sample avatar.
 * Take an image and flip it to face us left or right, and bounce when we're walking.
 */
[SWF(width="600", height="450")]
public class EasyImagePet extends Sprite
{
    public static const MAX_WIDTH :int = 600;
    public static const MAX_HEIGHT :int = 450;

    public function EasyImagePet ()
    {
        // set up the control and add a listener for when our appearance changes
        _ctrl = new PetControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.setTickInterval(5000);

        DataPack.load(_ctrl.getDefaultDataPack(), gotPack);
    }

    protected function gotPack (pack :DataPack) :void
    {
        _bounciness = pack.getNumber("bounciness");
        _bounceFreq = pack.getNumber("bounceFrequency");
        _right = pack.getBoolean("imageFacesRight");
        pack.getDisplayObjects("image", gotImage);
    }

    protected function gotImage (disp :DisplayObject) :void
    {
        _image = disp;
        _image.y = MAX_HEIGHT - _image.height;
        addChild(_image);
        _ctrl.setHotSpot(MAX_WIDTH / 2, MAX_HEIGHT, _image.height);

        // adjust bounciness by the room for bouncing
        _bounciness *= (MAX_HEIGHT - _image.height);

        // now that everything's loaded, we're ready to hear appearance changed events
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, setupVisual);

        // very important! We can't just assume we're standing when we first start up.
        // We could be the instance of our avatar on someone else's screen, so the person
        // wearing the avatar could already be moving or facing any direction, etc.
        setupVisual();
    }

    protected function tick (event :TimerEvent) :void
    {
        var oxpos :Number = _ctrl.getLogicalLocation()[0];
        var nxpos :Number = Math.random();
        _ctrl.setLogicalLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);
    }

    protected function setupVisual (... ignored) :void
    {
        var orient :Number = _ctrl.getOrientation();
        var isMoving :Boolean = _ctrl.isMoving();

        // make sure we're oriented correctly
        // (We discard nearly all the orientation information and only care if we're
        // facing left or right.)
        if (_right == (orient > 180)) {
            _image.x = (MAX_WIDTH + _image.width) / 2;
            _image.scaleX = -1;

        } else {
            _image.x = (MAX_WIDTH - _image.width) / 2;
            _image.scaleX = 1;
        }

        // if we're moving, make us bounce.
        if (_bounciness > 0 && _bouncing != isMoving) {
            _bouncing = isMoving;
            if (_bouncing) {
                _endBounce = false;
                _bounceBase = getTimer(); // note that time at which we start bouncing
                addEventListener(Event.ENTER_FRAME, handleEnterFrame);

            } else {
                _endBounce = true;
            }
        }
    }

    protected function handleEnterFrame (... ignored) :void
    {
        var now :Number = getTimer();
        var elapsed :Number = now - _bounceBase;
        while (elapsed > _bounceFreq) {
            if (_endBounce) {
                removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
                // stop bouncing: put us back on the ground
                _image.y = MAX_HEIGHT - _image.height;
                return;
            }
            elapsed -= _bounceFreq;
            _bounceBase += _bounceFreq; // give us less math to do next time..
        }

        var val :Number = elapsed * Math.PI / _bounceFreq;
        _image.y = MAX_HEIGHT - _image.height - (Math.sin(val) * _bounciness);
    }

//
//
//    /**
//     * This is called when an action event is triggered.
//     */
//    protected function handleActionTriggered (event :ControlEvent) :void
//    {
//        trace("action triggered: " + event.name + ", value: " + event.value);
//    }
//
//    /**
//     * This is called when your Pet's memory is updated.
//     */
//    protected function handleMemoryChanged (event :ControlEvent) :void
//    {
//        trace("memory changed: " + event.name + " -> " + event.value);
//    }
//
//

    protected function handleUnload (event :Event) :void
    {
        // always make sure we're not listening to ENTER_FRAME when we unload
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    /** How we communicate with whirled. */
    protected var _ctrl :PetControl;

    /** The image we're flippin' and bouncin'. */
    protected var _image :DisplayObject;

    protected var _bounceFreq :Number;

    protected var _bounciness :Number;

    protected var _right :Boolean;

    protected var _endBounce :Boolean;

    /** Are we currently bouncing? */
    protected var _bouncing :Boolean = false;

    /** The time at which the current bounce started. */
    protected var _bounceBase :Number;
}
}
