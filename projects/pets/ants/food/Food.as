package {

import flash.display.Sprite;
import flash.display.Bitmap;

import flash.events.Event;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

/**
 * A food source for ant colonies.
 */
[SWF(width="165", height="295")]
public class Food extends Sprite
{
    public function Food ()
    {
        addChild(Bitmap(new PICTURE()));

        _ctrl = new FurniControl(this);
        _ctrl.registerPropertyProvider(propertyProvider);
    }

    protected function propertyProvider (key :String) :Object
    {
        if ("ants:isFood" == key) {
            return true;
        } else if ("ants:takeFood" == key) {
            return 50;
        }

        // We don't support this key, so return null
        return null;
    }

    protected var _ctrl :FurniControl;

    [Embed(source="food.png")]
    protected static const PICTURE :Class;
}

}
