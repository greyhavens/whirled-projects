package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;

/**
 * An extremely simple pet that moves randomly around the room.
 */
[SWF(width="83", height="47")]
public class Roomba extends Sprite
{
    public function Roomba ()
    {
        addChild(_image = Bitmap(new ROOMBA()));
        scaleX = .25;
        scaleY = .25;

        _ctrl = new PetControl(this);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        _ctrl.setTickInterval(3000);
    }

    protected function tick (event :TimerEvent) :void
    {
        var oxpos :Number = _ctrl.getLogicalLocation()[0];
        var nxpos :Number = Math.random();
        _ctrl.setLogicalLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);
    }

    protected function appearanceChanged (event :ControlEvent) :void
    {
        var orient :Number = _ctrl.getOrientation();
        if (orient < 180) {
            _image.x = _image.width;
            _image.scaleX = -1;

        } else {
            _image.x = 0;
            _image.scaleX = 1;
        }
    }

    protected var _ctrl :PetControl;
    protected var _image :Bitmap;

    [Embed(source="roomba.png")]
    protected static const ROOMBA :Class;
}
}
