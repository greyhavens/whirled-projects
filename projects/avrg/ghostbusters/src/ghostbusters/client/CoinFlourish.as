//
// $Id$

package ghostbusters.client {

import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextFieldAutoSize;

import com.threerings.flash.Animation;
import com.threerings.flash.TextFieldUtil;

public class CoinFlourish extends Sprite
    implements Animation
{
    public function CoinFlourish (coins :int, done :Function)
    {
        _done = done;

        this.addChild(TextFieldUtil.createField(
            "You made " + coins + " coins!",
            {
                outlineColor: 0xFFFFFF,
                antiAliasType: AntiAliasType.ADVANCED,
                autoSize: TextFieldAutoSize.CENTER
            }, 
            {
                font: "Arial", size: 48, color: 0xFF7733
            })
        );
    }

    public function updateAnimation (elapsed :Number) :void
    {
        if (elapsed < 500) {
            this.alpha = elapsed / 500;

//        } else if (elapsed < 1000
//            this.alpha = 1;

        } else if (elapsed < 1000) {
            this.alpha = (1000 - elapsed) / 500;

        } else {
            this.alpha = 0;
            _done();
        }
    }

    protected var _done :Function;
}
}
