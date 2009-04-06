package vampire.avatar {

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.system.ApplicationDomain;

public class VampatarUpsellPanel extends Sprite
{
    public function VampatarUpsellPanel (url :String)
    {
        var panelClass :Class = getClass("popup_config");
        var panel :MovieClip = new panelClass();
        addChild(panel);

        var upsellButton :SimpleButton = panel["shop_button"];
        upsellButton.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                flash.net.navigateToURL(new URLRequest(url));
            });
    }

    protected static function getClass (name :String) :Class
    {
        return ApplicationDomain.currentDomain.getDefinition(name) as Class;
    }

}

}
