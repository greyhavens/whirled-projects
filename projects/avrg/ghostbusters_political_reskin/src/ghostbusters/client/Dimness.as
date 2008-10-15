//
// $Id$

package ghostbusters.client {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;

public class Dimness extends Sprite
{
    public function Dimness (alpha :Number, layer :Boolean)
    {
        if (layer) {
            this.blendMode = BlendMode.LAYER;
        }

        _front = new Sprite();
        _front.alpha = alpha;

        var g :Graphics = _front.graphics;
        g.beginFill(0xBCC9DA);
        g.drawRect(0, 0, 2000, 1000);
        g.endFill();

        this.addChild(_front);
    }

    public function getAlpha () :Number
    {
        return _front.alpha;
    }

    public function setAlpha (alpha :Number) :void
    {
        _front.alpha = alpha;
    }

    protected var _front :Sprite;
}
}
