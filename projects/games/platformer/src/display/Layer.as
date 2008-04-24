//
// $Id$

package display {

import flash.display.Sprite;

public class Layer extends Sprite
{
    public function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        if (_snapToPixel) {
            x = Math.floor(-nX);
            y = Math.floor(Metrics.DISPLAY_HEIGHT - nY);
        } else {
            x = -nX;
            y = Metrics.DISPLAY_HEIGHT - nY;
        }
    }

    /** Set to true and all coordinates will be floored. */
    protected var _snapToPixel :Boolean = true;
}
}
