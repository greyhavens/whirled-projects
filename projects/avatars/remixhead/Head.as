//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import com.whirled.AvatarControl;
import com.whirled.DataPack;

public class Head extends Sprite
{
    public function Head (ctrl :AvatarControl)
    {
        DataPack.load(ctrl.getDefaultDataPack(), gotPack);
    }

    protected function gotPack (pack :DataPack) :void
    {
        pack.getDisplayObjects("head", gotHead);
    }
    
    protected function gotHead (head :DisplayObject) :void
    {
        head.x = -head.width / 2;
        head.y = -head.height;
        addChild(head);
    }
}
}
