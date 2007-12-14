//
// $Id$

package ghostbusters {

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

        var front :Sprite = new Sprite();
        front.alpha = alpha;

        var g :Graphics = front.graphics;
        g.beginFill(0x000000);
        g.drawRect(0, 0, 2000, 1000);
        g.endFill();

        this.addChild(front);
    }
}
}
