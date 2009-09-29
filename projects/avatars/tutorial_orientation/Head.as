//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Sprite;

import com.threerings.util.Util;

import com.whirled.AvatarControl;

/**
 * A simple avatar with a rotating head.
 *
 * This demonstrates using flash 10's 3d abilities.
 */
[SWF(width="400", height="400")]
public class Head extends Sprite
{
    /**
     * Constructor: set up the avatar control, display list, and event listeners.
     */
    public function Head ()
    {
        // Create the AvatarControl
        _ctrl = new AvatarControl(this);
        // Set the hotspot to (200, 300), which is 100 pixels above the bottom since this
        // sprite is 400x400. The 3rd  parameter is the height of the name label above the hotspot,
        // giving us 50 more pixels above that in which to draw things.
        _ctrl.setHotSpot(200, 300, 250);

        // Create the head image, scale it down by half, and the center it within another sprite.
        var headImg :DisplayObject = new HEAD_IMAGE();
        headImg.scaleX = .5;
        headImg.scaleY = .5;
        headImg.x = -headImg.width/2;
        _head = new Sprite();
        _head.addChild(headImg);

        // Add the sprite containing the headImg as our child, positioning it above the hotspot.
        _head.x = 200;
        _head.y = 50;
        addChild(_head);

        // set up a listener for ENTER_FRAME events
        addEventListener(Event.ENTER_FRAME, rotateHead);
    }

    /**
     * Every frame, increase the head rotation by 1 degree.
     */
    protected function rotateHead (event :Event) :void
    {
        // Note that in a serious animation we would rotate based on time, as framerate can vary.
        _head.rotationY += 1;
    }

    /** Our avatar control. Used to communicate with whirled. */
    protected var _ctrl :AvatarControl;

    /** The sprite holding the head image. */
    protected var _head :Sprite;

    /** Our embedded head image. */
    [Embed(source="300_excorcist.jpg")]
    protected static const HEAD_IMAGE :Class;
}
}
