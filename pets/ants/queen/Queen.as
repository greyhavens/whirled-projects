package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.AvatarControl;
import com.whirled.EntityControl;

/**
 * The queen/hive that receives food from the workers.
 */
[SWF(width="386", height="382")]
public class Queen extends Sprite
{
    public function Queen ()
    {
        _ctrl = new AvatarControl(this);
        _ctrl.registerPropertyProvider(propertyProvider);

        addChild(Bitmap(new PICTURE()));
    }

    protected function propertyProvider (key :String) :Object
    {
        if (key == "ants:isQueen") {
            return true;
        }

        return null;
    }

    protected var _ctrl :AvatarControl;

    [Embed(source="queen.png")]
    protected static const PICTURE :Class;
}
}
