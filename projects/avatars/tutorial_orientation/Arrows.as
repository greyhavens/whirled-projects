//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

/**
 * An avatar that demonstrates the 360 degrees of rotation, using flash 10's simple 3d.
 */
[SWF(width="250", height="250")]
public class Arrows extends Sprite
{
    /**
     * Constructor: set up the avatar control, display list, and event listeners.
     */
    public function Arrows ()
    {
        // Set up the Arrows...
        createBody();

        // Create the AvatarControl
        _ctrl = new AvatarControl(this);
        // Set the hotspot to (125, 175), which is 75 pixels above the bottom since this
        // sprite is 250x250. The 3rd parameter is the height of the name label above the hotspot,
        // giving us 25 more pixels above that in which to draw things.
        _ctrl.setHotSpot(125, 175, 150);

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
    protected function createBody () :void
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
        bodyHolder.x = 125;
        bodyHolder.y = 175;
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
        // draw an arrow in the center of the sprite, pointing upward.
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

    /** The sprite holding the body. */
    protected var _body :Sprite;

    /** Our avatar control. Used to communicate with whirled. */
    protected var _ctrl :AvatarControl;
}
}
