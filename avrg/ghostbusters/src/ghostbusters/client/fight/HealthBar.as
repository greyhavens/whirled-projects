//
// $Id$

package ghostbusters.client.fight {

import flash.display.Graphics;
import flash.display.Sprite;

public class HealthBar extends Sprite
{
    public function HealthBar (width :int, height :int)
    {
        _width = width;
        _height = height;
    }

    public function updateHealth (percentHealth :Number) :void
    {
        var g :Graphics = this.graphics;
        g.clear();

        g.beginFill(HEALTH_BAR_COLOUR);
        g.drawRect(-width/2, -height/2, width * percentHealth, height);
        g.endFill();

        g.lineStyle(1, HEALTH_BORDER_COLOUR);
        g.drawRect(-width/2, -height/2, width, height);
    }

    protected var _width :int;
    protected var _height :int;

    protected static const HEALTH_BORDER_COLOUR :int = 0xFFFFFF;
    protected static const HEALTH_BAR_COLOUR :int = 0x22FF44;
}
}
