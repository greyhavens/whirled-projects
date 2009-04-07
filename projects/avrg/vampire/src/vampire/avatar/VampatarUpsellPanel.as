package vampire.avatar {

import com.whirled.AvatarControl;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;

public class VampatarUpsellPanel extends Sprite
{
    public function VampatarUpsellPanel (ctrl :AvatarControl, itemId :int)
    {
        var panelClass :Class = getClass("popup_config");
        var panel :MovieClip = new panelClass();
        addChild(panel);

        var upsellButton :SimpleButton = panel["shop_button"];
        upsellButton.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                ctrl.showPage("shop-l_5_" + itemId);
            });
    }

    protected static function getClass (name :String) :Class
    {
        return ApplicationDomain.currentDomain.getDefinition(name) as Class;
    }

}

}
