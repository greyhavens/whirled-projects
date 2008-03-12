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

    protected function gotPack (result :Object) :void
    {
        if (result is DataPack) {
            (result as DataPack).getDisplayObjects("head", gotHead);
        } else {
            gotHead(result);
        }
    }
    
    protected function gotHead (result :Object) :void
    {
        var head :DisplayObject;
        if (result is DisplayObject) {
            head = result as DisplayObject;

        } else {
            trace("Error loading head: " + result);
            // fake something up!
            var spr :Sprite = new Sprite();
            spr.graphics.beginFill(0xFF0000);
            spr.graphics.drawCircle(150, 150, 150);
            head = spr;
        }

        head.x = -head.width / 2;
        head.y = -head.height;
        addChild(head);
    }
}
}
