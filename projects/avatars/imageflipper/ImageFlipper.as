//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.utils.getTimer; // function import

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

/**
 * ImageFlipper. An extremely simple sample avatar.
 * Take an image and flip it to face us left or right, and bounce when we're walking.
 */
[SWF(width="161", height="170")] // the size of our image + BOUNCE pixels in the y direction.
public class ImageFlipper extends Sprite
{
    public function ImageFlipper ()
    {
        // create and add the image that represents us
        _image = (new IMAGE() as DisplayObject);
        _image.y = BOUNCE;
        addChild(_image);

        // set up the control and add a listener for when our appearance changes
        _ctrl = new AvatarControl(this);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, setupVisual);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);

        // very important! We can't just assume we're standing when we first start up.
        // We could be the instance of our avatar on someone else's screen, so the person
        // wearing the avatar could already be moving or facing any direction, etc.
        setupVisual();
    }

    protected function setupVisual (... ignored) :void
    {
        var orient :Number = _ctrl.getOrientation();
        var isMoving :Boolean = _ctrl.isMoving();

        // make sure we're oriented correctly
        // (We discard nearly all the orientation information and only care if we're
        // facing left or right.)
        if (orient < 180) {
            _image.x = _image.width;
            _image.scaleX = -1;

        } else {
            _image.x = 0;
            _image.scaleX = 1;
        }

        // if we're moving, make us bounce.
        if (_bouncing != isMoving) {
            _bouncing = isMoving;
            if (_bouncing) {
                _bounceBase = getTimer(); // note that time at which we start bouncing
                addEventListener(Event.ENTER_FRAME, handleEnterFrame);

            } else {
                removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
                // stop bouncing: put us back on the ground
                _image.y = BOUNCE;
            }
        }
    }

    protected function handleEnterFrame (... ignored) :void
    {
        var now :Number = getTimer();
        var elapsed :Number = now - _bounceBase;
        while (elapsed > BOUNCE_FREQUENCY) {
            elapsed -= BOUNCE_FREQUENCY;
            _bounceBase += BOUNCE_FREQUENCY; // give us less math to do next time..
        }

        var val :Number = elapsed * Math.PI / BOUNCE_FREQUENCY;
        _image.y = BOUNCE - (Math.sin(val) * BOUNCE);
    }

    protected function handleUnload (event :Event) :void
    {
        // always make sure we're not listening to ENTER_FRAME when we unload
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    /** How we communicate with whirled. */
    protected var _ctrl :AvatarControl;

    /** The image we're flippin' and bouncin'. */
    protected var _image :DisplayObject;

    /** Are we currently bouncing? */
    protected var _bouncing :Boolean = false;

    /** The time at which the current bounce started. */
    protected var _bounceBase :Number;

    //-------------------------------------------------------

    /** The height of our bounces. */
    protected static const BOUNCE :int = 20;

    /** The time to complete one bounce. */
    protected static const BOUNCE_FREQUENCY :int = 400;

    /** The image resource. */
    [Embed(source="rooster.jpg")]
    protected static const IMAGE :Class;
}
}
