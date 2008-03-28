//
//

package {

import flash.display.Sprite;

[SWF(width="100", height="100")]
public class Circle extends Sprite
{
    public function Circle ()
    {
        graphics.beginFill(0xFFFFFF, 0);
        graphics.drawCircle(50, 50, 50);
        graphics.endFill();
    }
}
}
