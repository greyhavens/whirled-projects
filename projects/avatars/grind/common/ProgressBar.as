package {

import flash.events.Event;
import flash.display.Sprite;

public class ProgressBar extends Sprite
{
    public var color :int;
    public var background :int;

    public function ProgressBar (color :int, background :int)
    {
        this.color = color;
        this.background = background;
    }

    public function set percent (p :Number) :void
    {
        p = Math.min(Math.max(0, p), 1);

        graphics.beginFill(color);
        graphics.drawRect(0, 0, 32*p, 4);
        graphics.endFill();

        graphics.beginFill(background);
        graphics.drawRect(32*p, 0, 32*(1-p), 4);
        graphics.endFill();
    }
}

}
