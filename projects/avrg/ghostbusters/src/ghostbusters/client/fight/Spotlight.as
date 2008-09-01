//
// $Id$

package ghostbusters.client.fight {

import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;

import com.threerings.util.Log;

public class Spotlight
{
    public var hole :Shape;

    public function Spotlight (playerId :int)
    {
        super();

        hole = new Shape();
        hole.blendMode = BlendMode.ERASE;

        hole.graphics.beginGradientFill(
            GradientType.RADIAL, [0, 0, 0], [1, 1, 0], [0, INNER, OUTER]);
        hole.graphics.drawCircle(0, 0, OUTER);
        hole.graphics.endFill();
    }

    public function redraw (x :Number, y :Number, width :Number, height :Number) :void
    {
        hole.x = x;
        hole.y = y;
        hole.scaleX = width / OUTER;
        hole.scaleY = height / OUTER;
    }

    protected static const INNER :int = 80;
    protected static const OUTER :int = 100;
}
}
