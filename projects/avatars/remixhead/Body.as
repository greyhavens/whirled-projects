//
// $Id$

package {

import flash.display.Sprite;

import com.whirled.AvatarControl;

[SWF(width="400", height="450")]
public class Body extends Sprite
{
    public function Body ()
    {
        _ctrl = new AvatarControl(this);

        var head :Head = new Head(_ctrl);
        head.x = 200;
        head.y = 150;
        addChild(head);
    }

    protected var _ctrl :AvatarControl;
}
}
