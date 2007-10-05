package
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL; // function import

/** Splash screen! */
public class Splash extends Sprite
{
    public static const HELP_URL :String = "http://wiki.whirled.com/Tangleword";
    
    public function Splash ()
    {
        var bg :DisplayObject = new Resources.splash();
        bg.x = bg.y = 0;
        addChild(bg);

        var help :Button = new Button(new Resources.buttonHelpOver(),
                                      new Resources.buttonHelpOut(),
                                      function () :void {
                                          navigateToURL(new URLRequest(HELP_URL));
                                      });
        position(help, Properties.HELP);
        addChild(help);

        // to prevent "this" reference confusion in play button handler
        var splash :Splash = this;
        var play :Button = new Button(new Resources.buttonPlayOver(),
                                      new Resources.buttonPlayOut(),
                                      function () :void {
                                          splash.parent.removeChild(splash);
                                      });
        position(play, Properties.PLAY);
        addChild(play);

        addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                event.stopPropagation();
            });
    }

    /** Helper function that updates display object position. */
    private function position (o :DisplayObject, p :Point) :void
    {
        o.x = p.x;
        o.y = p.y;
    }
}
}
    
