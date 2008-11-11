package {

import flash.events.Event;
import flash.display.Sprite;

public class HealthBar extends Sprite
{
    public function set percent (p :Number) :void
    {
        graphics.beginFill(0x00ff00);
        graphics.drawRect(0, 0, 32*p, 4);
        graphics.endFill();

        graphics.beginFill(0xff0000);
        graphics.drawRect(32*p, 0, 32*(1-p), 4);
        graphics.endFill();
    }
}

}
