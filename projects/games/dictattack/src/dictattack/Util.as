//
// $Id$

package dictattack {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;

/**
 * Would you believe, utility functions?
 */
public class Util
{
    public static function invokeLater (delay :int, func :Function) :void
    {
        var timer :Timer = new Timer(delay, 1);
        timer.addEventListener(TimerEvent.TIMER, func);
        timer.start();
    }

    public static function dump (object :Object, indent :String = "") :void
    {
        trace("D: " + indent + object);
        if (object is DisplayObjectContainer) {
            var doc :DisplayObjectContainer = (object as DisplayObjectContainer);
            for (var ii :int = 0; ii < doc.numChildren; ii++) {
                dump(doc.getChildAt(ii), indent + "+-");
            }
        }
    }

    public static function millisToMinSec (millis :int) :String
    {
        var mins :int = (millis / (60*1000));
        var secs :int = (millis / 1000) % 60;
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}

}
