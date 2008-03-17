//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.Sprite;

import com.whirled.AvatarControl;
import com.whirled.DataPack;

public class Head extends Sprite
{
    public static const WIDTH :int = 250;
    public static const HEIGHT :int = 250;

    public static const X_ATTACHMENT :Number = .5;
    public static const Y_ATTACHMENT :Number = .9;

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
        var actualWidth :Number;
        var actualHeight :Number;

        var head :DisplayObject;
        if (result is DisplayObject) {
            head = result as DisplayObject;
            actualWidth = head.loaderInfo.width;
            actualHeight = head.loaderInfo.height;
            // TODO: scale down larger?

        } else {
            trace("Error loading head: " + result);
            // fake something up!
            var spr :Sprite = new Sprite();
            spr.graphics.beginFill(0xFF0000);
            spr.graphics.drawEllipse(0, 0, WIDTH, HEIGHT);
            spr.graphics.endFill();
            actualWidth = WIDTH;
            actualHeight = HEIGHT;
            head = spr;
        }

        head.x = actualWidth * -X_ATTACHMENT;
        head.y = actualWidth * -Y_ATTACHMENT;
        addChild(head);
    }
}
}
