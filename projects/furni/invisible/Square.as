//
//

package {

import flash.display.Sprite;

[SWF(width="100", height="100")]
public class Square extends Sprite
{
    public function Square ()
    {
        graphics.beginFill(0xFFFFFF, 0);
        graphics.drawRect(0, 0, 100, 100);
        graphics.endFill();
    }
}
}
