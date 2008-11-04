package {

import flash.events.Event;
import flash.display.Sprite;

import caurina.transitions.Tweener;

public class HealthBar extends Sprite
{
    public function HealthBar ()
    {
    }

    public function set percent (p :Number) :void
    {
        trace("Setting percent " + p);
        graphics.beginFill(0x00ff00);
        graphics.drawRect(0, 0, 32*p, 4);
        graphics.endFill();

        graphics.beginFill(0xff0000);
        graphics.drawRect(32*p, 0, 32*(1-p), 4);
        graphics.endFill();

        trace("Done setting percent");
    }
}

}
