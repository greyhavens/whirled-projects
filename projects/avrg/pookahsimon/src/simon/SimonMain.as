//
// $Id$

package simon {

import com.threerings.util.Log;
import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import flash.display.Sprite;
import flash.events.Event;

[SWF(width="700", height="500")]
public class SimonMain extends Sprite
{
    public static var log :Log = Log.getLog(SimonMain);

    public static var control :AVRGameControl;
    //public static var model :Model;
    //public static var controller :Controller;

    public static var ourPlayerId :int;

    public function SimonMain ()
    {
    }
}

}
