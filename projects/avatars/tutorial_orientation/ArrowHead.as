//
// $Id$

package {

import flash.events.Event;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

/**
 * An avatar that demonstrates the 360 degrees of rotation, using flash 10's simple 3d.
 */
[SWF(width="400", height="400")]
public class ArrowHead extends Sprite
{
    /**
     * Constructor: set up the avatar control, display list, and event listeners.
     */
    public function ArrowHead ()
    {
        // Create the AvatarControl
        _ctrl = new AvatarControl(this);
        // Set the hotspot to (200, 300), which is 100 pixels above the bottom since this
        // sprite is 400x400. The 3rd  parameter is the height of the name label above the hotspot,
        // giving us 50 more pixels above that in which to draw things.
        _ctrl.setHotSpot(200, 300, 250);

        // Set up the Arrows...
        createArrows();

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

        // The whirled AvatarControl will send us an event every time our appearance changes.
        // Let's listen for that so that we can update our orientation.
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, updateAppearance);

        // And, one last thing: we need to make sure we update our appearance when we first
        // start up. We can't assume that the avatar is facing forward initially.
        // This should always be done in any avatar, checking the state and appearance on startup.
        updateAppearance(null);
    }

    /**
     * Create and set up the "body" of the avatar, made up of arrows in 3d space.
     */
    protected function createArrows () :void
    {
        // Create the body sprite that we will be rotating
        _body = new Sprite();

        var arrow :Sprite;

        // Make a red arrow for the "feet", rotated 90 degrees around the X axis, add it to body.
        arrow = makeArrow(0xFF0033);
        arrow.rotationX = 90;
        _body.addChild(arrow);

        // Make a yellow arrow for the "torso", unrotated, so it points straight up.
        arrow = makeArrow(0xFFFF00);
        _body.addChild(arrow);

        // The body needs to be positioned at the center of this sprite, but we also want to
        // rotate it around the Y axis, so we offset it inside a holder sprite.
        var bodyHolder :Sprite = new Sprite();
        bodyHolder.x = 200;
        bodyHolder.y = 300;
        bodyHolder.addChild(_body);
        addChild(bodyHolder);
    }

    /**
     * Creates a Sprite of an arrow in the specified color.
     */
    protected function makeArrow (color :uint) :Sprite
    {
        var arrow :Sprite = new Sprite();
        var g :Graphics = arrow.graphics;
        g.lineStyle(1, 0x000000);
        g.beginFill(color);
        g.moveTo(-30, 0);
        g.lineTo(-30, -75);
        g.lineTo(-75, -75);
        g.lineTo(0, -150);
        g.lineTo(75, -75);
        g.lineTo(30, -75);
        g.lineTo(30, 0);
        g.lineTo(-30, 0);
        g.endFill();
        return arrow;
    }

    /**
     * Every frame, increase the head rotation by 1 degree.
     */
    protected function rotateHead (event :Event) :void
    {
        // Note that in a serious animation we would rotate based on time, as framerate can vary.
        _head.rotationY += 1;
    }

    /**
     * When our appearance changes, update the rotation of the body.
     */
    protected function updateAppearance (event :ControlEvent) :void
    {
        // Get the orientation of our avatar in whirled. 0 faces forward and it rotates clockwise
        // from there.
        var orient :Number = _ctrl.getOrientation();

        // Rotate the entire body around the Y axis, converting whirled orientation into
        // a rotation. It's just counter-clockwise instead of clockwise, so we subtract it from 360.
        _body.rotationY = 360 - orient;

        // To add a bit of perspective and make it so we can actually see the red "feet" arrow,
        // let's rotate around the X axis by up to plus or minus 15 degrees.
        var radians :Number = orient * Math.PI / 180; // convert degrees to radians
        _body.rotationX = 15 * Math.cos(radians);
    }

    /** Our avatar control. Used to communicate with whirled. */
    protected var _ctrl :AvatarControl;

    /** The sprite holding the head image. */
    protected var _head :Sprite;

    /** The sprite holding the body. */
    protected var _body :Sprite;

    /** Our embedded head image. */
    [Embed(source="300_excorcist.jpg")]
    protected static const HEAD_IMAGE :Class;
}
}
