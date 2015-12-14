package {

import flash.display.Sprite;
import flash.display.Bitmap;

import flash.events.Event;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

/**
 * A food source for ant colonies.
 */
[SWF(width="102", height="69")]
public class Food extends Sprite
{
    public function Food ()
    {
        _ctrl = new FurniControl(this);
        _ctrl.registerPropertyProvider(propertyProvider);

        _image = Bitmap(new FOOD());
        addChild(_image);
    }

    protected function propertyProvider (key :String) :Object
    {
        if ("tutorial:takeFood" == key) {
            return Math.floor(Math.random()*20) + 1;
        }

        // We don't support this key, so return null
        return null;
    }


    protected var _ctrl :FurniControl;
    protected var _image :Bitmap;

    [Embed(source="food.png")]
    protected static const FOOD :Class;
}

}
