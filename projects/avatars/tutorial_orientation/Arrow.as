//
// $Id$

package {

import flash.display.Graphics;
import flash.display.Sprite;

import com.threerings.util.Util;

import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="400", height="400")]
public class Arrow extends Sprite
{
    public function Arrow ()
    {
        createArrows();

        _ctrl = new AvatarControl(this);
        _ctrl.setHotSpot(200, 300, 150);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, Util.adapt(updateAppearance));
        updateAppearance();
    }

    protected function createArrows () :void
    {
        var holder :Sprite = new Sprite();
        holder.x = 200;
        holder.y = 300;
        addChild(holder);

        _structure = new Sprite();
        holder.addChild(_structure);

        var arrow :Sprite;
        arrow = makeArrow(0xFF0033);
        arrow.rotationX = 90;
        _structure.addChild(arrow);

        arrow = makeArrow();
        _structure.addChild(arrow);
    }

    /**
     * Create an arrow of the specified color, pointing straight up, with the base at 0,0
     */
    protected function makeArrow (color :uint = 0xFFFF00) :Sprite
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

    protected function updateAppearance () :void
    {
        var orient :Number = _ctrl.getOrientation();

        _structure.rotationY = 360 - orient;

        var radians :Number = orient * Math.PI/180;
        trace("orient: " + orient + ", radians: " + radians + ", cos: " + Math.cos(radians)); 
        _structure.rotationX = 15 * Math.cos(radians);
    }

    protected var _ctrl :AvatarControl;

    protected var _structure :Sprite;
}
}
