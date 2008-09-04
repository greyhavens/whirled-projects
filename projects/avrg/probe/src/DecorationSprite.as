package {

import flash.display.Sprite;

public class DecorationSprite extends Sprite
{
    public function DecorationSprite ()
    {
        graphics.beginFill(0xff7f7f);
        graphics.drawCircle(0, 0, 10);
        graphics.endFill();
    }
}

}
